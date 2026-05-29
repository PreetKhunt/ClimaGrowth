import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ──────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String mobile,
    required String email,
    required String password,
    required String village,
    required double farmSize,
    required String language,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      mobile: mobile,
      email: email,
      village: village,
      farmSizeAcres: farmSize,
      language: language,
      theme: 'light',
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
    return cred;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // On web: Firebase popup flow (no google_sign_in needed, no client_id meta tag needed)
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final cred = await _auth.signInWithPopup(provider);
      await _upsertGoogleUser(cred.user!);
      return cred;
    } else {
      // On Android/iOS: native account picker via google_sign_in package
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut(); // force account picker every time
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _upsertGoogleUser(cred.user!);
      return cred;
    }
  }

  Future<void> _upsertGoogleUser(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'mobile': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'village': 'Padra',
        'farmSizeAcres': 1.0,
        'language': 'en',
        'theme': 'light',
        'authProvider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'photoUrl': user.photoURL ?? '',
      });
    }
  }

  // ── OTP (Phone) ──────────────────────────────────────────────────────────

  Future<void> verifyPhone({
    required String phone,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String, int?) codeSent,
    required void Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> confirmOtp(String verificationId, String smsCode) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(cred);
  }

  // ── User Data ────────────────────────────────────────────────────────────

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    // Refresh FCM token silently
    _refreshFcmToken(uid);
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> _refreshFcmToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _db
            .collection('users')
            .doc(uid)
            .update({'fcmToken': token});
      }
    } catch (_) {
      // Non-critical — silently ignore
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
    }
  }

  Future<void> signOut() async => _auth.signOut();
}
