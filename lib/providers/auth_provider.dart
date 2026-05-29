import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get loading => _loading;

  AuthProvider() {
    try {
      _service.authStateChanges.listen(_onAuthChanged);
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _status = AuthStatus.authenticated;
      _user = await _service.getUserProfile(firebaseUser.uid);
    }
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _service.signInWithEmail(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String name,
    required String mobile,
    required String email,
    required String password,
    required String village,
    required double farmSize,
    required String language,
  }) async {
    _setLoading(true);
    try {
      await _service.signUpWithEmail(
        name: name, mobile: mobile, email: email,
        password: password, village: village,
        farmSize: farmSize, language: language,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _service.sendPasswordReset(email);
    } finally {
      _setLoading(false);
    }
  }

  // ── OTP (Phone) – exposed for UI ────────────────────────────────────────

  Future<void> verifyPhone({
    required String phone,
    required void Function(String, int?) codeSent,
    required void Function(String) verificationFailed,
  }) async {
    _setLoading(true);
    try {
      await _service.verifyPhone(
        phone: phone,
        verificationCompleted: (_) {},
        verificationFailed: (e) => verificationFailed(e.message ?? 'Verification failed'),
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (_) {},
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> confirmOtp(String verificationId, String smsCode) async {
    _setLoading(true);
    try {
      await _service.confirmOtp(verificationId, smsCode);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final cred = await _service.signInWithGoogle();
      return cred != null;
    } on FirebaseAuthException catch (e) {
      _error = _authError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserModel updated) async {
    await _service.updateUserProfile(updated);
    _user = updated;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Enter a valid email address.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed': return 'Google sign-in is not enabled. Contact support.';
      case 'account-exists-with-different-credential': return 'Account exists with different sign-in method.';
      default: return 'Authentication error. Please try again.';
    }
  }
}
