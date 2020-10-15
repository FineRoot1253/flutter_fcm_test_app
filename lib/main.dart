import 'dart:async';

import 'package:fcm_tet_01_1008/controller/http_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// flutterLocalNotificationsPlugin 플러그인, backgroundhandler 위치때문에 여기에 선언 초기화
var flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final FirebaseMessaging fm = FirebaseMessaging();

  /// 미리 put을 해주어야 하위 위젯에서 편하게 to로 접근 가능함

  HttpController httpController = Get.put(HttpController());
  WebViewController webViewController = Get.put(WebViewController());
  @override
  void initState() {
    // TODO: implement initState
    // var initializationSettingsAndroid =
    // AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   iOS: initializationSettingsIOS,);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification:onSelectNotification);
    //
    //
    // fm.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // fm.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    //
    // fm.configure(
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     WebViewController.to.showDialog(username: null ,message:message);
    //     await WebViewController.to.checkAndReLoadUrl(WebViewController.to.wvc);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     message = WebViewController.to.fixMessageTitleAndBody(message);
    //     print("onResume: $message");
    //     WebViewController.to.showDialog(username: null ,message:message);
    //     await WebViewController.to.checkAndReLoadUrl(WebViewController.to.wvc);
    //   },
    //   onMessage: (Map<String, dynamic> message) async {
    //     message = WebViewController.to.fixMessageTitleAndBody(message);
    //     print("onMessage: $message");
    //     WebViewController.to.showDialog(username: null ,message:message);
    //     await WebViewController.to.checkAndReLoadUrl(WebViewController.to.wvc);
    //   },
    // );
    //
    // // 로그인시 토큰 전달, 저장 필요
    // fm.getToken().then((String token) {
    //   assert(token != null);
    //   print("Push Messaging token: $token");
    // });
    // //_firebaseMessaging.subscribeToTopic()으로 미리 토픽을 fc쪽에 구독(등록)한다.
    // fm.subscribeToTopic("ALL");
    super.initState();
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

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
  WebViewController controller = Get.put(WebViewController());

  /// FC message 체크용
  print("myBackgroundMessageHandler message: $message");

  /// notification ID
  int msgId = int.tryParse(message["data"]["msgId"].toString()) ?? 0;
  print("msgId $msgId");

  /// comment는 controller에 기재됨
  message = controller.fixMessageTitleAndBody(message);

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
      priority: Priority.high);

  /// 추후 IOS 테스트시 여기에도 추가를 해주어야 함, 현재는 default
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  /// 앞서 선언, 초기화 한 토대로 notification을 띄움
  await flutterLocalNotificationsPlugin.show(msgId, message["data"]["title"],
      message["data"]["body"], platformChannelSpecifics,
      payload: message["data"]["URL"]);



    return Future<void>.value();
}