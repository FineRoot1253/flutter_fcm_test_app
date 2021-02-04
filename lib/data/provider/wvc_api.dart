import 'dart:async';
import 'dart:collection';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/data/provider/dao.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/main.dart';
import 'package:fcm_tet_01_1008/screen/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';

class WVCApi {
  /// singleton logic START
  static WVCApi _instance;

  WVCApi._internal() {
    _instance = this;
  }

  factory WVCApi() => _instance ?? WVCApi._internal();

  /// singleton logic END
////////////////////////////////////////////////////////////////////////////////
  /// Api instances
  final fcmApiInstance = FCMApi();
  final flnApiInstance = FLNApi();
  final ajaxApiInstance = AJAXApi();
  final daoIns = DAOApi();

  /// FCM에서 받은 URL 변수, 체크 및 리로드용
  String receivedURL;

  /// 업체 Code
  String compCd;

  /// 업체 User Id
  String compUserId;

  /// 기기 토큰 변수
  String deviceToken;

  /// 유저의 로그인 타입
  String procType;

  /// 세션 스토리지의 내용이 들어가는 링크드해쉬맵, 쉬운 접근을 위해 여기에 선언
  LinkedHashMap<String, dynamic> ssItem;

  List<WebViewPage> _webViewPages = List<WebViewPage>();

  List<WebViewPage> get webViewPages => this._webViewPages;

  addWebViewPage(WebViewPage page) => this._webViewPages.add(page);

  removeLastWebViewPages() => this._webViewPages.removeLast();

  removeAtWebViewPages(int index) => this._webViewPages.removeAt(index);

  clearWebViewPages() => this._webViewPages.clear();

  /// init series logic START
  flnInit(void func(String payload)) async {
    await flnApiInstance.initFLN();
    await flnApiInstance.flnPlugin.initialize(
        flnApiInstance.initializationSettings,
        onSelectNotification: func,
        backgroundHandler: onPressNotificationAction);
  }

  fcmInit() async {
    fcmApiInstance.fcmPlugin.configure(
      onLaunch: _onFCMReceived,
      onResume: _onFCMReceived,
      onMessage: _onMessageReceived,
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    fcmApiInstance.fcmInitialize();

    ///  로그인시 토큰 체크용
    await fcmApiInstance.fcmPlugin.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
      this.deviceToken = token;
    });
  }

  // TODO: ajax 시작에 StreamController.add(),  끝부분엔 isloadDone()을 호출 할 것
  ajaxInit() {
    ajaxApiInstance.ajaxCompleter = Completer();
    ajaxApiInstance.ajaxStreamSubScription =
        ajaxApiInstance.ajaxStream.listen(_ajaxEventHandler);
  }

  /// init logic series END
  /// hiveDB는 컨트롤러 마다 필요 여부가 다르므로 컨트롤러 별로 알아서 할 것

  /// AJAX eventHandler
  void _ajaxEventHandler(AjaxRequest req) {
    print(req.readyState);
    if (req.readyState == AjaxRequestReadyState.DONE)
      ajaxApiInstance.ajaxCompleter.complete(req.readyState);
  }

  /// Resume + Launch 용 콜백
  Future<dynamic> _onFCMReceived(Map<String, dynamic> message) async {
    print("n\n\nonResume : $message\n\n\n");
  }

  /// background에서 접근 권한이 없음
  /// 빌드시 미리 이 핸들러를 TOP_LEVEL에 정의 OR static화 해두어야 isolate된 BackGround에서 접근 가능
  /// 현재 background용 콜백은 main.dart에 정의됨
  /// foreground용 콜백
  Future<dynamic> _onMessageReceived(Map<String, dynamic> message) async {
    print("\n\n\nonMessage : $message\n\n\n");
    if (ScreenHolderController.to.state != AppLifecycleState.inactive)
      flnApiInstance.addList(message);

    flnApiInstance.showNotification();
  }

  logoutProc() async {
    String logoutProcSource = """
      var xhttp = new XMLHttpRequest();
      xhttp.open("POST", "$LOGOUT_URL");
      xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xhttp.send("devToken=$deviceToken");
       """;

    print(ScreenHolderController.to.currentIndex);
    if (ScreenHolderController.to.currentIndex == 0) {
      await this
          ._webViewPages
          .first
          .viewModel
          .webViewController
          .evaluateJavascript(source: logoutProcSource);
    } else {
      await this
          ._webViewPages
          .last
          .viewModel
          .webViewController
          .evaluateJavascript(source: logoutProcSource);
      ScreenHolderController.to.onPressHomeBtn();
    }

    await ajaxApiInstance.ajaxCompleter.future;
  }

  initLogoutProc(String btnId) async {
    String addLogoutListenerSource = """
      var logoutBtn = document.getElementById('$btnId');
      logoutBtn.addEventListener("click", function (){
      console.log("logout");
      });
       """;

    (ScreenHolderController.to.currentIndex == 0)
        ? await this
            ._webViewPages
            .first
            .viewModel
            .webViewController
            .evaluateJavascript(source: addLogoutListenerSource)
        : await this
            ._webViewPages
            .last
            .viewModel
            .webViewController
            .evaluateJavascript(source: addLogoutListenerSource);

    await ajaxApiInstance.ajaxCompleter.future;
  }
}
