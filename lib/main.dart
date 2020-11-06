import 'dart:isolate';
import 'dart:ui';

import 'package:fcm_tet_01_1008/bindings/webview_binding.dart';
import 'package:fcm_tet_01_1008/data/provider/fcm_api.dart';
import 'package:fcm_tet_01_1008/data/provider/fln_api.dart';
import 'package:fcm_tet_01_1008/keyword/group_keys.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// fcm에 접근시키기위한 변수
final ReceivePort backGroundMessagePort = FCMApi().backGroundMessagePort;

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: WebViewBinding(),
      title: 'Flutter Demo',
      home: WebViewPage(),
      getPages: routes,
    );
  }
}

void main() async {
  /// 네이티브와 플러터를 바인드를 해줄때 initial 위치가 안맞는 경우가 있음,
  /// 그럴땐 이것을 추가
  WidgetsFlutterBinding.ensureInitialized();
  /// 최상위에서 위젯을 호출하기 전에 fcm_background_msg_isolate에 접근
  /// 아래의 IsolateNameServer는 static, isolate간 sendport 공유를 위해 존재
  /// registerPortWithName은 공유할 sendport 등록
  IsolateNameServer.registerPortWithName(backGroundMessagePort.sendPort, 'fcm_background_msg_isolate');

  /// myBackgroundMessageHandler는 fcm 백그라운드 isolate 영역
  /// 여기에 미리 등록한 sendport를 myBackgroundMessageHandler에서 호출해 send
  /// myBackgroundMessageHandler에서 send된 메시지는 여기서 받는다.
  //backGroundMessagePort.listen(myBackgroundMessagePortHandler);

  runApp(MyApp());
}

groupSummaryNotification(message,
    {String summaryText,
      int total,
      String groupTitle,
      String groupContent,
      List<String> lines}) async {
  final flnApiInstance = FLNApi();

  var _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', '비즈북스', '알람설정',
      setAsGroupSummary: true,
      groupKey: "GROUP_KEY",
      styleInformation: InboxStyleInformation(lines,
          contentTitle: summaryText, summaryText: '$total개의 안 읽은 알림'),
      color: Colors.blue.shade800,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("noti_icon"),
      priority: Priority.max);
  // flnApiInstance.flnPlugin.cancel()

  await flnApiInstance.flnPlugin.show(
      0,
      groupTitle ?? "group noti title",
      groupContent ?? "group noti body",
      NotificationDetails(
          android: _androidPlatformChannelSpecifics,
          iOS: IOSNotificationDetails()),
      payload: message["data"]["URL"]);
}


/// TOP_Level BackgroundMessageHandler
/// isolate domain
Future<dynamic> myBackgroundMessageHandler(dynamic message) async {
  /// 여기에서 한번 더 flutter_local_notification인스턴스에 접근할 필요가 있어서
  /// flutter_local_notification을 싱글톤화 해야했다.
  final flnApiInstance = FLNApi();

  var _androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', '비즈북스', '알람설정',
      groupKey: "GROUP_KEY",
      styleInformation: BigTextStyleInformation(message["data"]["body"],
          contentTitle: message["data"]["title"],
          summaryText: message["data"]["title"] + " 알림"),
      color: Colors.blue.shade800,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("noti_icon"),
      priority: Priority.max);
  var _iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var _platformChannelSpecifics = NotificationDetails(
      android: _androidPlatformChannelSpecifics,
      iOS: _iOSPlatformChannelSpecifics);

  /// notification ID
  int msgId = int.tryParse(message["data"]["msgType"].toString()) ?? 0;

  /// 게시판, 서류함 기타등등 메시지 종류별로 하나씩만 리스트에 넣기 위해 if문으로 중복을 체크
  if (!flnApiInstance.notificationList
      .contains("${message["data"]["msgType"]}")) {
    flnApiInstance.notificationList.add("${message["data"]["msgType"]}");
  }

  /// 앞서 선언, 초기화 한 토대로 notification을 띄움
  await flnApiInstance.flnPlugin.show(msgId, message["data"]["title"],
      message["data"]["body"], _platformChannelSpecifics,
      payload: message["data"]["URL"]+"msgId=0"+msgId.toString()+"&compCd=${message["data"]["compCd"]}");

  /// 날라온 fcm notification 메시지들을 그룹화 시켜서 띄워주는 메소드
  await groupSummaryNotification(message,
      summaryText: "${MESSAGE_TYPE_LIST[msgId]} 알림이 도착했습니다",
      groupTitle: MESSAGE_TYPE_LIST[msgId],
      groupContent: "${MESSAGE_TYPE_LIST[msgId]} 관련 알림이 도착해있습니다",
      total: flnApiInstance.notificationList.length,
      lines: flnApiInstance.notificationList);

  /// 이 메서드는 isolate domain -> 이 메서드 속 resource가 공유안됨

  /// 여기서는 앞서 등록한 sendport를 가져와 메시지를 send
  final SendPort port = IsolateNameServer.lookupPortByName('fcm_background_msg_isolate');
  port.send(flnApiInstance.notificationList);

  return Future<void>.value();
}

