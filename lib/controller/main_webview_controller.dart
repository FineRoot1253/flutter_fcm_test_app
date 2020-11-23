import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/data/repository/http_repository.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

/// 현재 컨트롤러에는  mvc 모델에 쓰이는 컨트롤러에 비해 다소 많은 기능이 추가되어있음
/// 웹뷰 url로딩을 직접 컨트롤할 용도로 사용을 하기 위해선
/// fcm api와 함께 동작을 해야하기 때문에 현재 상태를 기용중

class MainWebViewController extends GetxController {
  /// CV의 편한 연결을 위해 추가
  static MainWebViewController get to => Get.find();

  /// repository 연결
  final HttpRepository repository;

  MainWebViewController({@required this.repository}) : assert(repository != null);

  /// API 연결
  final wvcApiInstance = WVCApi();

  /// progress indicator용 변수
  double progress = 0;

  /// 로그인 체크 변수, 로그인 환영 메시지 호출 여부
  bool isSignin = false;

  /// 웹뷰 옵션
  InAppWebViewGroupOptions webViewGroupOptions;

  /// login temp userform
  Map<dynamic, dynamic> tempUserForm = Map<dynamic, dynamic>();

  ///  토큰 재발급 처리용 변수
  ///  토큰은 다음과 같은 상황에 자동으로 재발급된다.
  ///  1) deleteInstanceID를 호출할 때
  ///  2) 유저가 앱을 삭제할 때
  ///  플러그인에 onRefreshToken이 스트림으로 되어있고
  ///  사용을 할때는 아래의 StreamSubscription에 리슨을 걸어주면
  ///  알아서 2가지 상황에 재발급을 받는다.
  // StreamSubscription refreshing;

  /// view에서 로그인, 로그아웃 체크용도
  checkSignin(String currentURL) => _checkSignin(currentURL);

  ///progress 변경시 호출   TODO 자체 연산
  progressChanged(double progress) => _progressChanged(progress);

  /// view initstate에서 호출용
  initNotifications() async {
    /// TODO : WVCApi에 정의한 init들을 여기서 선언 할 것
    /// FLN + FCM + AJAX init START
    await wvcApiInstance.fcmInit();
    await wvcApiInstance.flnInit(onSelectNotification);
    wvcApiInstance.ajaxInit();
    /// FLN + FCM + init END

    /// 토큰 재발급 리슨, TODO: 추후 사용 필요시 주석제거
    // refreshing = fcmApiInstance.fcmPlugin.onTokenRefresh.listen((newToken) {
    //   this.deviceToken=newToken;
    //   print("디바이스 토큰 교체완료 : ${this.deviceToken}");
    // });

    /// WebViewModel init START ////////////////////////////////////////////////
    wvcApiInstance.mainWebViewModel=WebViewModel(
      url: MAIN_URL,
    );
    /// WebViewModel init END //////////////////////////////////////////////////


    /// WebViewGroupOptions init START /////////////////////////////////////////
    webViewGroupOptions = InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true
        ),
        crossPlatform: InAppWebViewOptions(
          javaScriptCanOpenWindowsAutomatically: true,
          clearCache: true,
          debuggingEnabled: true,
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: true,
          useOnLoadResource: true,
        )
    );
    /// WebViewGroupOptions init END ///////////////////////////////////////////

    return Future<void>.value();

  }
  /// 웹뷰 옵션 설정
  webViewGroupOptionSetter(bool isSignin){
    webViewGroupOptions=InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true
        ),
        crossPlatform: InAppWebViewOptions(
          javaScriptCanOpenWindowsAutomatically: true,
          clearCache: true,
          debuggingEnabled: true,
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: isSignin,
          useOnLoadResource: true,
        )
    );
  }


  /// payload 체크용
  Future onSelectNotification(String payload) async {
      final SendPort sendPort = IsolateNameServer.lookupPortByName(
          "fcm_background_isolate_return");
      Map<String, dynamic> payloadMap = jsonDecode(payload);

      if (!(payloadMap["msgType"] == 0)) {
        wvcApiInstance.flnApiInstance.notificationList
            .removeWhere((element) => element == payloadMap["msgType"]);
      } else {
        wvcApiInstance.flnApiInstance.notificationList.clear();
      }
      sendPort.send(wvcApiInstance.flnApiInstance.notificationList);
      /// 받은 URL,compCd 업데이트
      wvcApiInstance.receivedURL = payloadMap["URL"];
      wvcApiInstance.compCd = payloadMap["compCd"];
      wvcApiInstance.compUserId = payloadMap["userId"];
      // /// loginCheck 먼저하고 재로그인
      await _checkSignin(
          await wvcApiInstance.mainWebViewModel.webViewController.getUrl());

      /// 리로드 체크
      if (ScreenHodlerController.to.currentIndex == 1) {
        ScreenHodlerController.to.onPressHomeBtn();
      }
      print("로그인 여부 : $isSignin");
      if (isSignin) await checkAndReLoadUrl();


  }

  _checkSignin(String currentURL) async {
    ///로그인이후 결과인지 체크, 맞으면 로그인환영 스낵바 호출
    ///&&this.progress==-1 && !ssItem.isNull
    if (!wvcApiInstance.ssItem.isNull && !isSignin) {
      var username = wvcApiInstance.ssItem["user"]["userNm"];
      showItemSnackBar(message: null, username: username);
      isSignin = true;
      ScreenHodlerController.to.toggle=isSignin;
    }

    ///로그아웃하는 중인지 체크, 로그아웃하는 url이면 로그아웃절차 시작
    ///!ssItem.isNull, 로그인상태 여부 체크
    if (currentURL.endsWith("/login") && isSignin) {
      wvcApiInstance.ssItem = null;
      isSignin = false;
      //await logoutProc();
      ScreenHodlerController.to.toggle=isSignin;
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
    print("${wvcApiInstance.ssItem!=null} : ${!wvcApiInstance.compCd.isNull} : ${wvcApiInstance.receivedURL != "/"} : ${wvcApiInstance.ssItem["procType"]==2}");
    if (wvcApiInstance.ssItem!=null && !wvcApiInstance.compCd.isNull && wvcApiInstance.receivedURL != "/"&&wvcApiInstance.ssItem["procType"]==2) {
      ///TODO: url에 따라 나눠질 필요 있음 여기서 분기 추가해야함
      print("오지마 여기");
      String source7 = """
      try{
      document.getElementById("taxAgentKey").value="${wvcApiInstance.compCd}";
      document.getElementById("taxAgentUserId").value="${wvcApiInstance.compUserId}";
      var form = document.getElementById("bizbooksForm");
      console.log(document.getElementById("taxAgentKey").value + " : " + document.getElementById("taxAgentUserId").value);
      form.target = "_blank";
      form.method = "post";
      form.action = "/bizbooks_test/m/main";
      form.taxAgentKey.value = document.getElementById('taxAgentKey').value;
      form.submit();
            }catch(e){
      console.log(e);
      }
      """;

      await wvcApiInstance.mainWebViewModel.webViewController.evaluateJavascript(source: source7);
      await wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;

      wvcApiInstance.compCd=null;
      wvcApiInstance.compUserId=null;

    }else{
      await wvcApiInstance.mainWebViewModel.webViewController
          .loadUrl(
          url: (wvcApiInstance.receivedURL
              .endsWith("/board"))
              ? BOARD_URL
              : FILE_STORAGE_URL);
      wvcApiInstance.compCd=null;
      wvcApiInstance.compUserId=null;
      wvcApiInstance.receivedURL = null;
    }
  }

  autoLoginProc() async {
    String autoLoginProcSource = """
var xhttp = new XMLHttpRequest();
      xhttp.open("POST", "$TOKEN_LOGIN_URL", true);
      xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xhttp.send("devToken=${wvcApiInstance.deviceToken}");
       """;

      await wvcApiInstance.mainWebViewModel.webViewController.evaluateJavascript(source: autoLoginProcSource);
      await wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
      wvcApiInstance.ssItem = await SessionStorage(wvcApiInstance.mainWebViewModel.webViewController).getItem(key: "loginUserForm");
      if(wvcApiInstance.ssItem!=null) await wvcApiInstance.mainWebViewModel.webViewController.loadUrl(url: MAIN_URL+ ((wvcApiInstance.ssItem["procType"]==2 ) ? MAIN_URL_LIST[0] : MAIN_URL_LIST[1]));
      await checkSignin(await wvcApiInstance.mainWebViewModel.webViewController.getUrl());
  }

  ///progress 변경시 콜백
  _progressChanged(double progress) {
    this.progress = progress;
    update();
  }

}