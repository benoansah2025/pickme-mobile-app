import 'dart:convert';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: AndroidInitializationSettings('@mipmap/launcher_icon'),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      if (details.payload != null) {
        Map<String, dynamic> decodedData = jsonDecode(details.payload!);
        log(decodedData.toString());
        notificationNavigationService(decodedData);
      }
    },
  );
}

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void notificationNavigationService(Map<String, dynamic> payload) {
  //  mainNavigatorKey.currentState?.push(
  //     MaterialPageRoute(builder: (context) => const Vendors()),
  //   );
}