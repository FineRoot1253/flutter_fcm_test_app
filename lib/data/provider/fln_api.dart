import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FLNApi{
  /// 현 클래스 싱글톤화
  static FLNApi _instance;

  FLNApi._internal(){
    _instance = this;
  }
  factory FLNApi() => _instance ?? FLNApi._internal();

  final _flnPlugin= FlutterLocalNotificationsPlugin();
  var _platformChannelSpecifics;
  var _initializationSettings;
  /// 웹뷰 컨트롤러에서 init에 사용될 get들
  get initializationSettings => this._initializationSettings;
  get platformChannelSpecifics => this._platformChannelSpecifics;
  get flnPlugin => this._flnPlugin;

  var _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', '비즈북스', '알람설정',
      fullScreenIntent: true,
      color: Colors.blue.shade800,
      importance: Importance.high,
      largeIcon: DrawableResourceAndroidBitmap("noti_icon"),
      priority: Priority.high);
  var _iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var _initializationSettingsAndroid;
  var _initializationSettingsIOS;


  ///여기에서 local_notification을 초기화한다.
  ///이 메서드는 webviewinit 메서드쪽에서 호출해서 사용될 용도이다.
  void initFLN() {

    _initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/noti_icon');
    _initializationSettingsIOS = IOSInitializationSettings();
    _initializationSettings = InitializationSettings(
      android: _initializationSettingsAndroid,
      iOS: _initializationSettingsIOS,
    );
    _platformChannelSpecifics = NotificationDetails(
        android: _androidPlatformChannelSpecifics,
        iOS: _iOSPlatformChannelSpecifics);
  }
}