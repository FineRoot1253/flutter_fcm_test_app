import 'dart:async';
import 'dart:convert';

import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/data/provider/dao.dart';
import 'package:fcm_tet_01_1008/keyword/group_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class FLNApi {

  final dbIns = DAOApi();

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
  // List<MessageModel> backGroundNotiList = List<MessageModel>();
  List<MessageModel> _notiListContainer;

  /// notification Page 관리용 스트림
  StreamController<String> msgStrCnt = StreamController.broadcast();

  Stream<String> get msgStream => msgStrCnt.stream;

  StreamSubscription<String> msgSub;

  ///여기에서 local_notification을 초기화한다.
  ///이 메서드는 webviewinit 메서드쪽에서 호출해서 사용될 용도이다.
  initFLN() async {
    // isSupported = await FlutterAppBadger.isAppBadgeSupported();
     await _requestPermission();
       /// TODO: 종료 필요

    /// TODO : platform분기 필요
    _initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/renew_app_icon');
    _initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
      const IOSNotificationCategory(
      'demoCategory',
      <IOSNotificationAction>[
        IOSNotificationAction('id_1', '확인', options: <IOSNotificationActionOption>{IOSNotificationActionOption.foreground}),
        IOSNotificationAction(
          'id_2',
          '닫기',
          options: <IOSNotificationActionOption>{
            IOSNotificationActionOption.destructive,
          },
        ),
      ],
      options: <IOSNotificationCategoryOption>{
        IOSNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
      ]);
    _androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'fcm_default_channel', '비즈북스', '알람설정',
        color: Colors.blue.shade800,
        importance: Importance.max,
        channelShowBadge: true,
        largeIcon: DrawableResourceAndroidBitmap("app_icon"),
        priority: Priority.max,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'id_1',
            '확인',
            icon: DrawableResourceAndroidBitmap('app_icon'),
          ),
          AndroidNotificationAction(
            'id_2',
            '닫기',
            icon: DrawableResourceAndroidBitmap('app_icon'),
          ),
        ]
    );
    this._initializationSettings = InitializationSettings(
      android: _initializationSettingsAndroid,
      iOS: _initializationSettingsIOS,
    );

    this._platformChannelSpecifics = NotificationDetails(
        android: _androidPlatformChannelSpecifics,
        iOS: _iOSPlatformChannelSpecifics);

    if(this._notiListContainer == null)
      await initNotificationListContainer();

  }

  Future<void> initNotificationListContainer() async {



    this._notiListContainer = await dbIns.getList();
    print("getList done : ${this._notiListContainer.length}");

    return Future.value(1);
  }

  Future<void> setNotiListContainer() async {

    await dbIns.setList(this._notiListContainer);

    return Future<void>.value();
  }

  List<MessageModel> get notiListContainer => this._notiListContainer;

  addList(Map<String,dynamic> message){
    print("하나 추가");

    try{
      this.notiListContainer.add(MessageModel(msgType: message["data"]["msgType"],
          title: message["data"]["title"],
          body: message["data"]["body"],
          compCd: message["data"]["compCd"],
          url: message["data"]["URL"],
          userId: message["data"]["userId"],
          compNm: message["data"]["compNm"],
          receivedDate: DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now())
      ));
      this.msgStrCnt.add("event!");
    }catch(e,s){
      print(s);
    }
  }

  removeLastNotification()  {
    this.notiListContainer.removeLast();
    this.msgStrCnt.add("add");
  }

  removeAtNotification(int index){
    this.notiListContainer.removeAt(index);
    this.msgStrCnt.add("remove");
  }

  clearNotifications(){
    this.notiListContainer.clear();
    this.msgStrCnt.add("clear");
  }

  Future<bool> _requestPermission() async {
    return this._flnPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  showLoginNotification(){
    this._flnPlugin
        .show(3, "환영합니다", "비즈북스에 로그인하셨습니다.", this._platformChannelSpecifics);
    this._flnPlugin
        .cancel(3);
  }

  showNotification(){
    this._flnPlugin
        .show(int.tryParse(notiListContainer.last.msgType) ?? -1, notiListContainer.last.title, notiListContainer.last.body, this._platformChannelSpecifics,payload: jsonEncode(notiListContainer.last.toMap()));
  }

  listRemoveProc(MessageModel msg){
    notiListContainer.removeWhere((element) => element.receivedDate==msg.receivedDate&&element.msgType==msg.msgType);
  }

  List<MessageModel> getLines(){

    List<MessageModel> result = List<MessageModel>();

    MESSAGE_TYPE_LIST.forEach((typeListElement) {
      result.add(notiListContainer.lastWhere((notificationListElement) => notificationListElement.msgType == typeListElement));
    });

    return result;
  }

}
