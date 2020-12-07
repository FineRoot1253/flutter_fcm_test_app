import 'dart:async';

import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

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

  var _androidPlatformChannelSpecifics;
  var _iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var _initializationSettingsAndroid;
  var _initializationSettingsIOS;

  /// notification 그룹 관리용 변수
  List<MessageModel> backGroundNotiList = List<MessageModel>();
  List<MessageModel> notiListContainer = List<MessageModel>();

  /// notification Page 관리용 스트림
  StreamController<String> msgStrCnt = StreamController.broadcast();

  Stream<String> get msgStream => msgStrCnt.stream;

  StreamSubscription<String> msgSub;
  bool isSupported;

  ///여기에서 local_notification을 초기화한다.
  ///이 메서드는 webviewinit 메서드쪽에서 호출해서 사용될 용도이다.
  initFLN() async {
    isSupported = await FlutterAppBadger.isAppBadgeSupported();

    /// TODO : platform분기 필요
    _initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/renew_app_icon');
    _initializationSettingsIOS = IOSInitializationSettings();
    _androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'fcm_default_channel', '비즈북스', '알람설정',
        color: Colors.blue.shade800,
        importance: Importance.max,
        channelShowBadge: !isSupported,
        largeIcon: DrawableResourceAndroidBitmap("app_icon"),
        priority: Priority.max);
    _initializationSettings = InitializationSettings(
      android: _initializationSettingsAndroid,
      iOS: _initializationSettingsIOS,
    );

    _platformChannelSpecifics = NotificationDetails(
        android: _androidPlatformChannelSpecifics,
        iOS: _iOSPlatformChannelSpecifics);
  }

  addList(Map<String,dynamic> message){
    try{
      notiListContainer.add(MessageModel(msgType: message["data"]["msgType"],
          title: message["data"]["title"],
          body: message["data"]["body"],
          compCd: message["data"]["compCd"],
          url: message["data"]["URL"],
          userId: message["data"]["userId"],
          compNm: message["data"]["compNm"],
          receivedDate: DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now())
      ));
      msgStrCnt.add("event!");
    }catch(e,s){
      print(s);
    }
  }

  removeLastNotification()  {
    notiListContainer.removeLast();
    msgStrCnt.add("add");
  }

  removeNotification(int index){
    notiListContainer.removeAt(index);
    msgStrCnt.add("remove");
  }

  clearNotifications(){
    notiListContainer.clear();
    msgStrCnt.add("clear");
  }

}
