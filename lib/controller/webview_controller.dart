import 'dart:collection';
import 'package:fcm_tet_01_1008/data/provider/fcm_api.dart';
import 'package:fcm_tet_01_1008/data/repository/http_repository.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewController extends GetxController {
  /// CV의 편한 연결을 위해 추가
  static WebViewController get to => Get.find();

  /// repository 연결
  final HttpRepository repository;
  WebViewController({@required this.repository}) : assert(repository != null);


  /// API 연결
  final fcmApiInstance = FCMApi();

  /// FCM에서 받은 URL 변수, 체크 및 리로드용
  String receivedURL;

  ///기기 토큰 변수
  String deviceToken;

  ///로그인 체크 변수, 로그인 환영 메시지 호출 여부
  bool isSignin = false;

  ///onProgressChange가 2번 호출되는 문제로 중복 back 방지용
  bool isLoadDone = false;

  /// 웹뷰의 웹뷰 컨트롤러, 쉬운 접근을 위해 여기에 선언
  InAppWebViewController wvc;

  /// 세션 스토리지의 내용이 들어가는 링크드해쉬맵, 쉬운 접근을 위해 여기에 선언
  LinkedHashMap<String, dynamic> ssItem;

  ///progress indicator용 변수
  double progress = 0;

  /// view에서 로그인, 로그아웃 체크용도
  checkSignin(String currentURL) => _checkSignin(currentURL);

  ///progress 변경시 호출
  progressChanged(double progress) => _progressChanged(progress);

  /// view initstate에서 호출용
  initNotifications() async {
    fcmApiInstance.fcmPlugin.configure(
      onLaunch: _onFCMReceived,
      onResume: _onFCMReceived,
      onMessage: _onMessageReceived,

      /// main에 미리 선언 해둔 콜백 func
      /// background에서 접근 권한이 없음
      /// 빌드시 미리 이 핸들러를 TOP_LEVEL에 선언 OR static화 해두어야 isolate된 BackGround에서 접근 가능
      /// 현 상황에서 사용불가
      // onBackgroundMessage: myBackgroundMessageHandler,
    );
    fcmApiInstance.fcmInitialize();

    ///  로그인시 토큰 체크용, TODO: 추후 DB에 저장 필요
    fcmApiInstance.fcmPlugin.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
      print("token length : ${token.length}");
      this.deviceToken=token;
    });
  }

  Future<dynamic> _onMessageReceived(Map<String, dynamic> message) async {
   showItemSnackBar(username: null, message: message);
    await checkAndReLoadUrl();
  }
  Future<dynamic> _onFCMReceived(Map<String, dynamic> message) async {
    print("\n\n\n\n\n\n\n\n\n\nonResume : $message\n\n\n\n\n\n\n\n\n");
    onSelectNotification(message["data"]["URL"]);
    await checkAndReLoadUrl();
  }

  ///progress 변경시 콜백
  _progressChanged(double progress) {
    this.progress = progress;

    update();

    if(progress==1.0&&!this.isLoadDone){
      this.isLoadDone=true;
      this.progress=0;
      Get.back();
    }
  }

  /// payload 체크용
  Future onSelectNotification(String payload) async {

    /// 받은 URL 업데이트
    String res = payload ?? null;
    if (!(res == null)) {
      receivedURL = payload;
    }

    /// 리로드 체크
    await checkAndReLoadUrl();
  }


  ///TODO 추후 확장성을 위해 global 화 필요

  _checkSignin(String currentURL) {
    ///로그인이후 결과인지 체크, 맞으면 로그인환영 스낵바 호출
    if (!ssItem.isNull && !isSignin&&this.progress==0) {
      var username = ssItem["user"]["userNm"];
      showItemSnackBar(message: null, username: username);
      isSignin = true;
    }

    ///로그아웃하는 중인지 체크, 로그아웃하는 url이면 로그아웃절차 시작
    ///!ssItem.isNull, 로그인상태 여부 체크
    if (currentURL.endsWith("/m/") && !ssItem.isNull) {
      ssItem = null;
      isSignin = false;
    }
  }

  /// checkAndReLoadUrl(), fcm에서 링크가 보내지면 리로드 동작, 평소에는 URL변수가 null -> 체크후 return;
  /// fcm의 의해 새로운 링크가 추가되었는지 체크 -> 웹뷰 리로드 -> URL변수 null 초기화
  Future<void> checkAndReLoadUrl() async {
    ///FCM onResume callback & InAppWebView onLoadStart
    ///this.wvc=controller; -> 넣는 위치에 따라 필요여부 있음
    ///push notification or snackBar 에 의해 한번 거치게되면 receivedURL=null,
    ///세션스토리지 Null 유무로 로그인체크
    ///-> 재호출시 리로드가 되지 않아야 함
    ///receivedURL.isNull -> notification을 타고 왔는지 구분 가능
    if (!ssItem.isNull && !receivedURL.isNull && receivedURL != "/") {
      await wvc.loadUrl(url: MAIN_URL + receivedURL);
      receivedURL = null;
    }
  }
}
