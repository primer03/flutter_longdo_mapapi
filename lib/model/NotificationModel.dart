import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:getgeo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationModel {
  String? title;
  String? body;
  String? image;
  String? time;

  NotificationModel({this.title, this.body, this.image, this.time});

  void shownotification({String? title, String? body}) async {
    const String channelId = "PRIMO";
    const String channelName = "PRIMO";

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notification = prefs.getBool('notification') ?? true;
    bool notificationsound = prefs.getBool('notificationsound') ?? true;
    print("notificationsound: $notificationsound");
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'PRIMO',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: notificationsound,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    if (notification) {
      flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
        payload: 'XDXD',
      );
    }
  }

  void showNotificationAfterDelay(
      {String? title, String? body, required Duration delay}) async {
    const String channelId = "PRIMO";
    const String channelName = "PRIMO";

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notification = prefs.getBool('notification') ?? true;
    bool notificationsound = prefs.getBool('notificationsound') ?? true;

    final DateTime afterDelay = DateTime.now().add(delay);
    // final Person person = const Person(name: 'Primo', key: '1');
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'This is a notification channel for Primo',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: notificationsound,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    if (notification) {
      flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        title,
        body,
        tz.TZDateTime.from(afterDelay, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void shownotificationAtTime(TimeOfDay time) async {
    const String channelId = "XX";
    const String channelName = "HEEXYAI";

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool notification = prefs.getBool('notification') ?? true;
    bool notificationsound = prefs.getBool('notificationsound') ?? true;
    // final Person person = const Person(name: 'Heeyai', key: '1');
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'KUY',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: notificationsound,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    final DateTime now = DateTime.now();
    print("${time.hour},${time.minute}");
    final DateTime notificationTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (notificationTime.isBefore(now)) {
      notificationTime.add(Duration(days: 1));
    }

    if (notification) {
      flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        title,
        body,
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
