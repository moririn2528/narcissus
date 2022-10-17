import 'dart:convert';
import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

void init_notification() {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/notification',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white),
        NotificationChannel(
            channelGroupKey: 'image_test',
            channelKey: 'image',
            channelName: 'image notifications',
            channelDescription: 'Notification channel for image tests',
            defaultColor: Colors.redAccent,
            ledColor: Colors.white,
            channelShowBadge: true,
            importance: NotificationImportance.High)
      ],
      debug: true);
}

Future<void> notifyNow() async {
  AwesomeNotifications().createNotification(
      content: NotificationContent(
    id: 12345,
    channelKey: 'image',
    title: 'タップしました',
    body: 'タップしました',
    largeIcon: 'https://www.fluttercampus.com/img/logo_small.webp',
    notificationLayout: NotificationLayout.BigPicture,
  ));
}

Future<void> notifyLater(FlutterLocalNotificationsPlugin flnp) async {
  Timer(Duration(seconds: 5), () async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 12345,
      channelKey: 'image',
      title: '5秒前にタップしました',
      body: '5秒前にタップしました',
      largeIcon: 'https://www.fluttercampus.com/img/logo_small.webp',
      notificationLayout: NotificationLayout.BigPicture,
    ));
  });
}

Future<void> notifyPlant() async {
  getNearPlant().then((data) {
    if (data.isNotEmpty) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
        id: 12345,
        channelKey: 'image',
        title: '近くに植物があります',
        body: '近くに${data[0]['name']}があります',
        largeIcon: 'https://www.fluttercampus.com/img/logo_small.webp',
        notificationLayout: NotificationLayout.BigPicture,
      ));
    }
  }, onError: (e) {
    print(e);
  });
}

Future<List> getNearPlant() async {
  await http.get(Uri.parse('http://${dotenv.get('API_IP')}/api/near')).then(
      (value) {
    if (value.statusCode == 200) {
      final List data = jsonDecode(value.body);
      if (data.isNotEmpty) {
        return data;
      }
    }
  }, onError: (e) {
    print(e);
  });
  return [];
}

void call_periodic_notification() {
  Timer.periodic(Duration(seconds: 5), (timer) async {
    await notifyPlant();
  });
}
