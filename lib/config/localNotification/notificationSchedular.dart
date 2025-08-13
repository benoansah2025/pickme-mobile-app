import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationScheduler() {
    _initNotifications();
  }

  void _initNotifications() {
    tz.initializeTimeZones();
    const settingsAndroid = AndroidInitializationSettings('app_icon'); // replace with your icon
    const DarwinInitializationSettings settingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: settingsAndroid, iOS: settingsDarwin);

    flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> scheduleNotification({
    required DateTime dateTime,
    required String title,
    required String body,
    required int notificationId,
  }) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        _nextInstanceOfDaily(scheduledDate),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily_reminder_channel_id', 'Daily Reminder Notifications'),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  // Function for next instance of weekly notification
  tz.TZDateTime _nextInstanceOfDaily(tz.TZDateTime dateTime) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );

    return scheduledDate;
  }

  Future<void> deleteNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> deleteAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> requestPermissions() async {
    // For iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android 13 and above, use permission_handler
    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        debugPrint('Notification permission granted');
        return true;
      } else {
        debugPrint('Notification permission denied');
        return false;
      }
    }
    return true;
  }
}
