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

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    WebViewController.to.receivedURL = data["URL"];

  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController wvc;
  HttpController httpController = HttpController.to;
  WebViewController webViewController = WebViewController.to;

  @override
  void initState() {
    // TODO: implement initState
    webViewController.fm.configure(
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //build단에서 나머지를 configure해야 hotreload 사용가능
    webViewController.fm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // webViewController.showDialog(message);
        webViewController.navigateDialog(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // webViewController.showDialog(message);
        webViewController.navigateDialog(message);
      },
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        webViewController.showDialog(message);
      },
    );
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
                  this.wvc = controller;
                  // Session or Session Storage에 접근시 , wvc.session or wvc.sessionStorage로 접근 가능
                  // ookieManager 쿠키에도 접근 가능
                },
                onLoadStart:
                    (InAppWebViewController controller, String url) async {
                  this.wvc = controller;
                  String currentURL = await this.wvc.getUrl();
                  SessionStorage ss = SessionStorage(this.wvc);
                  LinkedHashMap<String, dynamic> ssItem =
                      await ss.getItem(key: "loginUserForm");
                  var username =
                      (ssItem.isNull) ? null : ssItem["user"]["userNm"];
                  if(currentURL.endsWith("/m/")&&webViewController.isSignin){
                    webViewController.isSignin=false;
                    ssItem=null;
                  }
                  if (!webViewController.isSignin && !ssItem.isNull) {
                    int sec = 5;
                    Get.snackbar("", "",
                        titleText: Text("환영합니다 $username님!", textAlign: TextAlign.center,),
                        backgroundColor: Colors.white,
                        borderWidth: 10.0,
                        borderColor: Colors.white,
                        borderRadius: 30.0,
                        duration: Duration(seconds: sec),
                        messageText:
                            Container(
                              padding: const EdgeInsets.only(top: 30.0),
                              margin: const EdgeInsets.only(bottom: 30.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  FlatButton(onPressed: (){}, child: Text("확인")),
                                  FlatButton(onPressed: (){}, child: Text("닫기"))
                                ],
                              ),
                            ));
                    webViewController.isSignin=true;
                  }
                  // Session or Session Storage에 접근시 , wvc.session or wvc.sessionStorage로 접근 가능
                  // url로 판단 가능
                  if (!ssItem.isNull &&
                      webViewController.receivedURL.isNotEmpty) {
                    await this
                        .wvc
                        .loadUrl(url: MAIN_URL + webViewController.receivedURL);
                    webViewController.receivedURL = "";
                  }
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
