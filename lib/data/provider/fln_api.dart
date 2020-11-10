import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FLNApi {
  /// 현 클래스 싱글톤화
  static FLNApi _instance;

  FLNApi._internal() {
    _instance = this;
  }

  factory FLNApi() => _instance ?? FLNApi._internal();

  final FlutterLocalNotificationsPlugin _flnPlugin =
      FlutterLocalNotificationsPlugin();
  var _platformChannelSpecifics;
  var _initializationSettings;

  /// 웹뷰 컨트롤러에서 init에 사용될 get들
  get initializationSettings => this._initializationSettings;

  get platformChannelSpecifics => this._platformChannelSpecifics;

  FlutterLocalNotificationsPlugin get flnPlugin => this._flnPlugin;

  set platformChannelSpecifics(NotificationDetails details) {
    this.platformChannelSpecifics = details;
  }

  var _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', '비즈북스', '알람설정',
      fullScreenIntent: false,
      color: Colors.blue.shade800,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("app_icon"),
      priority: Priority.max);
  var _iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var _initializationSettingsAndroid;
  var _initializationSettingsIOS;

  /// notification 그룹 관리용 변수
  List<String> notificationList = List<String>();
  List<int> idList = List<int>();

  ///여기에서 local_notification을 초기화한다.
  ///이 메서드는 webviewinit 메서드쪽에서 호출해서 사용될 용도이다.
  void initFLN() {
    _initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/app_icon');
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