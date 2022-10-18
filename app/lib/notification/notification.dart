import 'dart:convert';
import 'dart:developer';
import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../location/location.dart';
import '../handle_api/handle.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

void init_notification() async {
  var notifiation_permission =
      await Permission.notification.request().then((value) async {
    if (value == PermissionStatus.granted) {
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
      );
      final service = FlutterBackgroundService();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStart: true,
          isForegroundMode: true,
          initialNotificationTitle: 'AWESOME SERVICE',
          initialNotificationContent: 'Initializing',
        ),
        iosConfiguration: IosConfiguration(),
      );
    } else {
      return false;
    }
  });
}

late LocationPermission permission;

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

Future<LocationPermission> getPermission() async {
  permission = await Geolocator.checkPermission();
  return permission;
}

Future<void> onStart(ServiceInstance service) async {
  call_notification();
}

void call_notification() async {
  getPermission().then((value) {
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Timer.periodic(Duration(seconds: 5), (timer) {
        Geolocator.getCurrentPosition().then((value) {
          currentPosition = value;
          if (distanceBetween(lastPosition, currentPosition) >= 0) {
            notifyNow();
            // notifyPlant(currentPosition);
          }
          lastPosition = currentPosition;
        });
      });
    }
  });
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

Future<void> notifyPlant(Position? position) async {
  if (position == null) {
    return;
  } else {
    getNearPlant(position).then((data) {
      if (data.isNotEmpty) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
          id: 12345,
          channelKey: 'image',
          title: '近くに植物があります',
          body: '近くに${data[0]['id']}があります',
          largeIcon: 'https://www.fluttercampus.com/img/logo_small.webp',
          notificationLayout: NotificationLayout.BigPicture,
        ));
      }
    }, onError: (e) {
      print(e);
    });
  }
}
