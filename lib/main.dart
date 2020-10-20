import 'dart:async';
import 'package:fcm_tet_01_1008/controller/http_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// flutterLocalNotificationsPlugin 플러그인, backgroundhandler 위치때문에 여기에 선언 초기화
var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  /// 미리 put을 해주어야 하위 위젯에서 편하게 to로 접근 가능함
  final HttpController httpController = Get.put(HttpController());
  final WebViewController webViewController = Get.put(WebViewController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:'Flutter Demo',
      home:WebViewPage(),
      getPages: routes,
    );
  }
}

void main() async {
  /// 네이티브와 플러터를 바인드를 해줄때 initial 위치가 안맞는 경우가 있음,
  /// 그럴땐 이것을 추가
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// TOP_Level BackgroundMessageHandler
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  /// controller는 GET 특성상 TOP_LEVEL일 경우엔 그냥 put을 해주는 것이 맞음
  /// Get.put() -> C+V 연결, view에서 controller로 접근시 필수
  WebViewController webViewController = Get.put(WebViewController());

  /// comment는 controller에 기재됨
  message = webViewController.fixMessageTitleAndBody(message);

  /// FC message 체크용
  print("myBackgroundMessageHandler message: $message");

  /// notification ID
  int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  print("msgId $msgId");


  /// 안드로이드용 체널 구성
  /// fullScreenIntent -> notificaiton 호출시 화면에 크게 띄움
  /// color -> 색조정
  /// importance -> notification 중요도
  /// priority -> notification 우선도, 우선도에 따라 백그라운드 작동이 달라짐 유의할 것
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', 'your channel name', 'your channel description',
      fullScreenIntent: true,
      color: Colors.blue.shade800,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("noti_icon"),
      priority: Priority.high);

  /// 추후 IOS 테스트시 여기에도 추가를 해주어야 함, 현재는 default
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  /// 앞서 선언, 초기화 한 토대로 notification을 띄움
  await webViewController.plugin.show(msgId, message["data"]["title"],
      message["data"]["body"], platformChannelSpecifics,
      payload: message["data"]["URL"]);
    return Future<void>.value();
}