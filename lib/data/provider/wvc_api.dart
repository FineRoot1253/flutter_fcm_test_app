import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/data/provider/hive_api.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/main.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class WVCApi {

  /// singleton logic START
  static WVCApi _instance;

  WVCApi._internal(){
    _instance = this;
  }

  factory WVCApi() => _instance ?? WVCApi._internal();
  /// singleton logic END

////////////////////////////////////////////////////////////////////////////////

  /// Api instances
  final fcmApiInstance = FCMApi();
  final flnApiInstance = FLNApi();
  final ajaxApiInstance = AJAXApi();
  final hiveApiInstance = HiveApi();
  final SendPort sendPort = IsolateNameServer.lookupPortByName(
      "fcm_background_isolate_return");
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

  /// WebViewModel set
  WebViewModel _mainWebViewModel;
  WebViewModel _subWebViewModel;

  WebViewModel get mainWebViewModel => _mainWebViewModel;
  WebViewModel get subWebViewModel => _subWebViewModel;

  set mainWebViewModel(WebViewModel model){this._mainWebViewModel=model;}
  set subWebViewModel(WebViewModel model){this._subWebViewModel=model;}

  Box box;

  /// init series logic START
  flnInit(void func(String payload)) async {
    flnApiInstance.initFLN();
    await flnApiInstance.flnPlugin.initialize(flnApiInstance.initializationSettings,onSelectNotification: func);
  }

  fcmInit() async {
    fcmApiInstance.fcmPlugin.configure(
      onLaunch: _onFCMReceived,
      onResume: _onFCMReceived,
      onMessage: _onMessageReceived,
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    fcmApiInstance.fcmInitialize();
    /// fcmApiInstance.backGroundMessagePort
    /// fcm서버에서 message받음 1)
    /// 아래 onData 발동됨 2)
    /// fcm mybackgroundMessageHanlder는 2가지 동작을 수행 3)
    /// 3_1) flnApi.flnplugin.show를 수행
    /// 3_2) this.flnApiInstance.notificationList send
    /// 아래의 listen에서 send된 notificationList를 업데이트 4)
    fcmApiInstance.backGroundMessagePort.listen((message) {
      if(message is List<MessageModel>) {
        this.flnApiInstance.notiList=message;
        flnApiInstance.msgStrCnt.add("event!");
      }
      else this.flnApiInstance.notificationList=message;
      print("MAIN ISOLATE : ${this.flnApiInstance.notificationList} : ${this.flnApiInstance.notiList.length}");

    });

    ///  로그인시 토큰 체크용
    await fcmApiInstance.fcmPlugin.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
      this.deviceToken = token;
    });

  }
  hiveInit() async {
    try {
      await hiveApiInstance.init();
      box = await hiveApiInstance.getBox;
      flnApiInstance.notiList = await box.get("notiList", defaultValue: []).cast<MessageModel>()??List<MessageModel>();
    }catch(e,s){
      print(s);
    }
  }
    // TODO: ajax 시작에 StreamController.add(),  끝부분엔 isloadDone()을 호출 할 것
  ajaxInit(){
    ajaxApiInstance.ajaxCompleter=Completer();
    ajaxApiInstance.ajaxStreamSubScription = ajaxApiInstance.ajaxStream.listen(_ajaxEventHandler);
  }
  /// init logic series END
  /// hiveDB는 컨트롤러 마다 필요 여부가 다르므로 컨트롤러 별로 알아서 할 것


  /// AJAX eventHandler
  void _ajaxEventHandler(AjaxRequest req){
    if(req.readyState==AjaxRequestReadyState.DONE) ajaxApiInstance.ajaxCompleter.complete(req.readyState);
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
    flnApiInstance.addList(message);
    showItemSnackBar(username: null, message: message);
  }

  logoutProc() async {
    String autoLoginProcSource1 = """
      var xhttp = new XMLHttpRequest();
      xhttp.open("POST", "$LOGOUT_URL");
      xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xhttp.send("devToken=$deviceToken");
       """;
    if(ScreenHodlerController.to.currentIndex==0) await mainWebViewModel.webViewController.evaluateJavascript(source: autoLoginProcSource1);
    else{
      await subWebViewModel.webViewController.evaluateJavascript(source: autoLoginProcSource1);
      ScreenHodlerController.to.onPressHomeBtn();
    }

    await ajaxApiInstance.ajaxCompleter.future;

  }

  initLogoutProc(String btnId) async {
    String autoLoginProcSource2 = """
      var logoutBtn = document.getElementById('$btnId');
      logoutBtn.addEventListener("click", function (){
      console.log("logout");
      });
       """;

    (ScreenHodlerController.to.currentIndex==0) ?
    await mainWebViewModel.webViewController.evaluateJavascript(source: autoLoginProcSource2) :
    await subWebViewModel.webViewController.evaluateJavascript(source: autoLoginProcSource2);

    await ajaxApiInstance.ajaxCompleter.future;
  }

}