import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/offline_cache_service.dart';

/// Must be a top-level function (not a class method) for FCM background handling.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Log or store background alert silently — no UI available here
  final data = message.data;
  if (data['type'] == 'alert') {
    await NotificationService.showLocalAlert(
      title: message.notification?.title ?? 'ClimaGrowth Alert',
      body: message.notification?.body ?? '',
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only (no-op on web/desktop)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Firebase — wrapped so the app launches even without real credentials
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Background FCM handler is Android/iOS only (not supported on web/desktop)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  } catch (_) {
    // Firebase unavailable (placeholder credentials). Auth/chat persistence
    // will be disabled; weather and AI features still work via HTTP.
    debugPrint('ClimaGrowth: Firebase init skipped — run flutterfire configure');
  }

  // Hive offline cache
  await OfflineCacheService.init();

  // Local + FCM notifications (FCM portion skipped if Firebase unavailable)
  try {
    await NotificationService.init();
  } catch (_) {
    debugPrint('ClimaGrowth: Notifications init skipped');
  }

  runApp(const ClimaGrowthApp());
}
