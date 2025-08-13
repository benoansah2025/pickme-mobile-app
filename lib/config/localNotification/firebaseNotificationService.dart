import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notificationService.dart';

void setupFirebaseMessaging() {
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      log("=====getInitialMessage");
      log(message.data.toString());
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // Handle when the notification is clicked and the app opens
    log("=====onMessageOpenedApp");
   notificationNavigationService(message.data);
  });

  // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
  //   // Handle background message
  //   log("=====firebaseMessagingBackgroundHandler");
  //   log(message.data.toString());
  // });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;

    if (notification != null) {
      final NotificationDetails notificationDetails = NotificationDetails(
        android: android != null
            ? AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                icon: android.smallIcon,
              )
            : null,
        iOS: apple != null ? const DarwinNotificationDetails() : null,
      );

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  });
}
