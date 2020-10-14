import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:fcm_tet_01_1008/controller/http_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print("리즘 체크");
  if(message.containsKey("data")) {
    print("체크");
    WebViewController.to.showNotification(
        message["data"]["title"], message["data"]["body"]);
    await WebViewController.to.checkAndReLoadUrl(WebViewController.to.wvc);
  }
  return Future<void>.value();
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {


  HttpController httpController = HttpController.to;
  WebViewController webViewController = WebViewController.to;



  @override
  void initState() {
    // TODO: implement initState
    webViewController.fm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        webViewController.showDialog(username: null ,message:message);
        //webViewController.navigateDialog(message);
        await webViewController.checkAndReLoadUrl(webViewController.wvc);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        webViewController.showDialog(username: null ,message:message);
        //webViewController.navigateDialog(message);
        await webViewController.checkAndReLoadUrl(webViewController.wvc);
      },
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //WebViewController.to.showNotification(message["notification"]["title"], message["notification"]["body"]);
        webViewController.showDialog(username: null ,message:message);
        await webViewController.checkAndReLoadUrl(webViewController.wvc);
      },
      //TODO 백그라운드 콜백function은 테스트 필요, 1) static, 2) init단
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    webViewController.fm.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    webViewController.fm.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    // 로그인시 토큰 전달, 저장 필요
    webViewController.fm.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });
    //_firebaseMessaging.subscribeToTopic()으로 미리 토픽을 fc쪽에 구독(등록)한다.
    webViewController.fm.subscribeToTopic("ALL");
    webViewController.initNotifications();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //build단에서 나머지를 configure해야 hotreload 사용가능
    return SafeArea(
      top: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          reverse: true,
          physics: NeverScrollableScrollPhysics(),
          child: Container(
            height: Get.height - MediaQuery.of(context).padding.top,
            width: Get.width,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: InAppWebView(
                initialUrl: MAIN_URL,
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                        useShouldOverrideUrlLoading: true)),
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController.wvc = controller;
                  // Session or Session Storage에 접근시 , wvc.session or wvc.sessionStorage로 접근 가능
                  // ookieManager 쿠키에도 접근 가능
                },
                onLoadStart:
                    (InAppWebViewController controller, String url) async {
                  //URLLoad시작
                  //시작시 현 컨트롤러 업데이트 & 세션스토리지 로드 + 업데이트 -> 로그인 체크 가능
                  webViewController.wvc = controller;
                  String currentURL = await webViewController.wvc.getUrl();
                  SessionStorage ss = SessionStorage(webViewController.wvc);
                  webViewController.ssItem = await ss.getItem(key: "loginUserForm");
                  webViewController.checkSignin(currentURL);
                    //로그인 환영메시지 호출, 세션스토리지 not null&&webViewController.isSignin false
                    // -> 로그인중인것으로 판단

                  //리로드 + 체크용도
                  await webViewController.checkAndReLoadUrl(webViewController.wvc);

                },
                shouldOverrideUrlLoading:
                    (controller, shouldOverrideUrlLoadingRequest) async {
                  var url = shouldOverrideUrlLoadingRequest.url;
                  var uri = Uri.parse(url);
                  return ShouldOverrideUrlLoadingAction.ALLOW;
                  // 만약 강제로 리다이렉트, 등등을 원할 경우 여기서 url 편집
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
