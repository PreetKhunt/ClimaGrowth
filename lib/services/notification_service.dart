import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request FCM permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Local notifications init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create notification channel (Android)
    const channel = AndroidNotificationChannel(
      'climagrowth_channel',
      'ClimaGrowth Alerts',
      description: 'Weather and farm alerts from ClimaGrowth',
      importance: Importance.high,
    );
    await _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    // Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  static Future<String?> getToken() => _fcm.getToken();

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _local.show(
      notification.hashCode,
      notification.title ?? 'ClimaGrowth',
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'climagrowth_channel',
          'ClimaGrowth Alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> showLocalAlert({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'climagrowth_channel',
          'ClimaGrowth Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
