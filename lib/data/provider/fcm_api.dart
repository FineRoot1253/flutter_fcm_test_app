import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class FCMApi{

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  /// fcm에 접근시키기위한 변수

  FirebaseMessaging get fcmPlugin => _fm;
  Stream<RemoteMessage> get onMessageStream => FirebaseMessaging.onMessage;

  Future fcmInitialize() async {
    await this._fm.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    NotificationSettings settings = await this._fm.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    print(settings.authorizationStatus.toString());
  }

}