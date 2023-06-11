import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../location/location.dart';
import '../handle_api/handle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

@pragma('vm:entry-point')
void timer_notification(int value) {
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
  Timer.periodic(Duration(seconds: 6), (Timer timer) {
    // Geolocator.getCurrentPosition().then((value) {
    // currentPosition = value;
    if (distanceBetween(lastPosition, currentPosition) >= 0) {
      // notifyPlant(value);
      notifyNow();
    }
    lastPosition = currentPosition;
    // });
  });
}

void init_notification() async {
  Future<LocationPermission> getPermission() async {
    late var permission;
    permission = await Geolocator.checkPermission();
    return permission;
  }

// Future<void> onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
//   call_notification();
// }
  void call_notification() async {
    getPermission().then((value) {
      if (value == LocationPermission.always ||
          value == LocationPermission.whileInUse) {
        FlutterIsolate.spawn(timer_notification, 1);
      }
    });
  }

  var notifiation_permission =
      await Permission.notification.request().then((value) async {
    if (value == PermissionStatus.granted) {
      AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/notification',
        [
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
      // final service = FlutterBackgroundService();
      // await service.configure(
      //   androidConfiguration: AndroidConfiguration(
      //     onStart: onStart,
      //     autoStart: true,
      //     isForegroundMode: true,
      //   ),
      //   iosConfiguration: IosConfiguration(),
      // );
      call_notification();
      AwesomeNotifications().createNotification(
          content: NotificationContent(
        id: 12345,
        channelKey: 'image',
        title: 'wow',
        body: 'wow',
        largeIcon: 'https://www.fluttercampus.com/img/logo_small.webp',
        notificationLayout: NotificationLayout.BigPicture,
      ));
    } else {
      print('通知の許可がありません');
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
  Timer(Duration(seconds: 10), () async {
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
  var data = [];
  if (position == null) {
    return;
  } else {
    getNearPlant(position).then((posts) {
      data = posts;
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
      throw (e);
    });
  }
}
