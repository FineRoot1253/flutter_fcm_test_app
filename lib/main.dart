import 'dart:convert';
import 'dart:io';

import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/data/provider/dao.dart';
import 'package:fcm_tet_01_1008/keyword/group_keys.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/screen_holder.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:core';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: ScreenHolder(),
      getPages: routes,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 파일 다운로더 플러그인,  isolate로 동작, debug true시 console log print
  await FlutterDownloader.initialize(debug: true);

  await Permission.storage.request();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MyApp());

}

void onPressNotificationAction(Map<String, dynamic> record) async {}

/// 그룹핑 메서드
groupSummaryNotification(
  model, {
  String summaryText,
  int total,
  String groupTitle,
  String groupContent,
  List<MessageModel> lines,
}) async {
  final flnApiInstance = FLNApi();
  var _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', '비즈북스', '알람설정',
      setAsGroupSummary: true,
      groupKey: "GROUP_KEY",
      channelAction: AndroidNotificationChannelAction.update,
      styleInformation: InboxStyleInformation(
          List<String>.from(lines.map((e) => e.msgType).toList()),
          contentTitle: summaryText,
          summaryText: '$total개의 안 읽은 알림'),
      color: Colors.blue.shade800,
      importance: Importance.max,
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
      ]);

  await flnApiInstance.flnPlugin.show(
      0,
      groupTitle ?? "group noti title",
      groupContent ?? "group noti body",
      NotificationDetails(
          android: _androidPlatformChannelSpecifics,
          iOS: IOSNotificationDetails()),
      payload: jsonEncode(model.toMap()));
  print("printDone");
}

/// TOP_Level BackgroundMessageHandler
/// isolate domain
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try{
    print("[백그라운드]메시지 도착 ${message.data.toString()}");
    final flnApiInstance = FLNApi();
    final daoIns = DAOApi();
    await Firebase.initializeApp();

    await flnApiInstance.initFLN();
    MessageModel lastOne;
    MessageModel model;

    if (flnApiInstance.notiListContainer.length > 0)
      lastOne = flnApiInstance.notiListContainer.last;

    flnApiInstance.addList(message.data);

    await daoIns.setList(flnApiInstance.notiListContainer);
    await flnApiInstance.initNotificationListContainer();
    model = flnApiInstance.notiListContainer.last;

    /// 앞서 선언, 초기화 한 토대로 notification을 띄움
    await flnApiInstance.showNotification();
    /// 날라온 fcm notification 메시지들을 그룹화 시켜서 띄워주는 메소드

    await daoIns.closeBox();

    return Future<void>.value();
  }catch(e,s){
    print(e);
    print(s);
  }
}

int getMsgLength(List<MessageModel> list, String msgType) =>
    list.where((e) => e.msgType == msgType).toList().length;
