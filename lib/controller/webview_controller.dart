import 'dart:collection';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

//TODO: item Getobs로 연결, 연결이후 변환까지 필요
class WebViewController extends GetxController {
  static WebViewController get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String receivedURL;

  //로그인 체크 변수, 로그인 환영 메시지 호출 여부
  bool isSignin = false;

  InAppWebViewController wvc;
  LinkedHashMap<String, dynamic> ssItem;

  FirebaseMessaging get fm => _firebaseMessaging;

  showDialog(
          {@required String username,
          @required Map<String, dynamic> message}) =>
      _showItemDialog(username: username, message: message);

  checkSignin(String currentURL) => _checkSignin(currentURL);

  //TODO: 이동 => true 반환, 반환시 urlOverloading 시켜야함 Webview 연동 필수
  //TODO: 다이얼로그 이원화 필요, 로그인시 or 다른 업무 알람
  //TODO: 현재 다이얼로그 -> Get.dialog 필요
  //TODO: 모든 다이얼로그 -> 커스텀 스낵바로 변환
  FlutterLocalNotificationsPlugin plugin;
  initNotifications() async {
    plugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification:onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,iOS: initializationSettingsIOS);
    await plugin.initialize(initializationSettings);
  }
  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page

  }
  Future<void> showNotification(String title, String body) async {
    print("ㅁㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄻㄴㅇㄹ");
    var android = AndroidNotificationDetails(
        'fcm_default_channel', 'channelName', 'channelDescription',
        fullScreenIntent: true,
        priority: Priority.high,
        importance: Importance.high,
        visibility: NotificationVisibility.public);
    var iOS = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
      await plugin
         .show(0, "title", "body", platform, payload: "asdfasdf");
  }

  void _showItemDialog(
      {@required String username,
      @required Map<String, dynamic> message}) async {
    var titleStr;
    var bodyStr;

    if(message.containsKey("data")) {
        titleStr = message["data"]["title"] ?? '알림';
        bodyStr = message["data"]["body"] ?? '';
    }

    // await
    Get.snackbar("", "",
        isDismissible: false,
        titleText: Text(
          (username.isNull) ? "$titleStr" : "어서오세요 $username님",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        borderWidth: 10.0,
        borderColor: Colors.white,
        borderRadius: 30.0,
        duration: Duration(seconds: 5),
        messageText: Container(
          padding: const EdgeInsets.only(top: 30.0),
          margin: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (username.isNull) ? Text("$bodyStr") : Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (username.isNull)
                      ? FlatButton(
                          onPressed: () {
                            this.receivedURL = message["data"]["URL"];
                            checkAndReLoadUrl(this.wvc).then((_) => Get.back());
                          },
                          child: Text("확인"))
                      : Container(),
                  FlatButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text("닫기"))
                ],
              ),
            ],
          ),
        ));
  }

  _checkSignin(String currentURL) {
    if (!ssItem.isNull && !isSignin) {
      var username = ssItem["user"]["userNm"];
      ////////////////////////////////////////////////////////////
      //TODO: showDialog를 커스텀 스낵바로 교체후 showDialog로 교체할 것
      _showItemDialog(message: null, username: username);
      ////////////////////////////////////////////////////////////
      isSignin = true;
    }

    //로그아웃하는 중인지 체크, 로그아웃하는 url이면 로그아웃절차 시작
    //!ssItem.isNull 으로 로그인상태 여부 체크
    if (currentURL.endsWith("/m/") && !ssItem.isNull) {
      ssItem = null;
      print("로그아웃 완료 : ${ssItem.isNull}");
      isSignin = false;
    }
  }

  //TODO: 현재 routing -> Get으로 변경 필요

  Future<void> checkAndReLoadUrl(InAppWebViewController controller) async {
    //FCM onResume callback & InAppWebView onLoadStart
    //this.wvc=controller; -> 넣는 위치에 따라 필요여부 있음
    //push notification or snackBar 에 의해 한번 거치게되면 receivedURL=null,
    //세션스토리지 Null 유무로 로그인체크
    //-> 재호출시 리로드가 되지 않아야 함
    //receivedURL.isNull -> notification을 타고 왔는지 구분 가능

    print("리로드 사용 여부 체크 : ${!ssItem.isNull} : ${!receivedURL.isNull}");
    if (!ssItem.isNull && !receivedURL.isNull) {
      await wvc.loadUrl(url: MAIN_URL + receivedURL);
      receivedURL = null;
    }
  }
}
