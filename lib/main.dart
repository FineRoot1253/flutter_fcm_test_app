import 'dart:async';

import 'package:fcm_tet_01_1008/controller/http_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

//backgroundMessageHandler로 미리 static or 최상위에 선언 필수
//백그라운드 플러그인을 백그라운드(네이티브 단)에서 빌드 할때 콜백함수가 반드시 필요하기 때문

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  HttpController httpController = Get.put(HttpController());
  WebViewController webViewController = Get.put(WebViewController());
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
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}