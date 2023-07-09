import 'Dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../handle_api/handle.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';

@pragma('vm:entry-point')
class NotificationController {
  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    print('Notification Received');
  }

  static Future<void> init_notification() async {
    await Permission.notification.request();
    await AwesomeNotifications().initialize(
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
        debug: true);
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> notifyNow() async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 12345,
      channelKey: 'image',
      title: 'タップしました',
      body: 'タップしました',
      notificationLayout: NotificationLayout.BigPicture,
    ));
  }

  DateTime lastNotificationTime = DateTime.now();

  Future<void> notifyPlant(LocationData position, DateTime dt) async {
    var data = [];
    if (dt.difference(lastNotificationTime).inSeconds < 180) {
      return;
    }
    print("try to notify");
    if (position == null) {
      return;
    } else {
      getNearPlant(position).then((posts) {
        data = posts.plants_list;
        if (data.isNotEmpty) {
          AwesomeNotifications().createNotification(
              content: NotificationContent(
            id: 12345,
            channelKey: 'image',
            title: '近くに植物があります',
            body: '近くに${data[0].name}があります',
          ));
          print("notified");
          lastNotificationTime = DateTime.now();
        }
      }, onError: (e) {
        throw (e);
      });
    }
  }
}
