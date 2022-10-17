import 'dart:convert';
import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../location/location.dart';
import '../handle_api/handle.dart';

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

class Notifier {
  var permission;
  Notifier() {
    getPermission();
  }

  Position lastPosition = Position(
      latitude: 0,
      longitude: 0,
      altitude: 0,
      accuracy: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      isMocked: false);
  Position currentPosition = Position(
      latitude: 0,
      longitude: 0,
      altitude: 0,
      accuracy: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: DateTime.now(),
      isMocked: false);

  void getPermission() async {
    permission = await Geolocator.checkPermission();
  }

  void call_periodic_notification() async {
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await Geolocator.getCurrentPosition().then((value) {
        currentPosition = value;
        if (distanceBetween(lastPosition, currentPosition) > 100) {
          Timer.periodic(Duration(seconds: 5), (timer) async {
            await notifyPlant();
          });
        }
      });
      lastPosition = currentPosition;
    }
  }
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

Future<void> notifyLater() async {
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
