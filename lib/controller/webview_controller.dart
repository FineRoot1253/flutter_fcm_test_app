import 'dart:async';
import 'dart:convert';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'screen_holder_controller.dart';

/// 현재 컨트롤러에는  mvc 모델에 쓰이는 컨트롤러에 비해 다소 많은 기능이 추가되어있음
/// 웹뷰 url로딩을 직접 컨트롤할 용도로 사용을 하기 위해선
/// fcm api와 함께 동작을 해야하기 때문에 현재 상태를 기용중

class WebViewController extends GetxController {
  /// CV의 편한 연결을 위해 추가
  static WebViewController get to => Get.find();

  /// API 연결
  final wvcApiInstance = WVCApi();

  /// progress indicator용 변수
  double progress = 0;

  /// 로그인 체크 변수, 로그인 환영 메시지 호출 여부
  bool isSignin = false;

  /// Error 체크 변수
  bool isError = false;
  bool _isInited = false;


  /// login temp userform
  Map<dynamic, dynamic> tempUserForm = Map<dynamic, dynamic>();

  ///  토큰 재발급 처리용 변수
  ///  토큰은 다음과 같은 상황에 자동으로 재발급된다.
  ///  1) deleteInstanceID를 호출할 때
  ///  2) 유저가 앱을 삭제할 때
  ///  플러그인에 onRefreshToken이 스트림으로 되어있고
  ///  사용을 할때는 아래의 StreamSubscription에 리슨을 걸어주면
  ///  알아서 2가지 상황에 재발급을 받는다.

  ///  view에서 로그인, 로그아웃 체크용도
  checkSignin(String currentURL) => _checkSignin(currentURL);

  ///progress 변경시 호출   TODO 자체 연산
  progressChanged(double progress) => _progressChanged(progress);

  /// view initstate에서 호출용
  initNotifications() async {
    try{ /// TODO : WVCApi에 정의한 init들을 여기서 선언 할 것
      /// FLN + FCM + AJAX init START
      if(this._isInited)  return Future.value(1);

      await wvcApiInstance.fcmInit();
      await wvcApiInstance.flnInit(onSelectNotification);
      wvcApiInstance.ajaxInit();
      /// FLN + FCM + init END

      print("초기화 완료");
      this._isInited = true;
      return Future.value(1);
    }catch(e ,s){
      print(e);
      print(s);
    }
  }

  /// payload 체크용
  Future onSelectNotification(String payload) async {

    print("셀렉트");
    print(payload);

    try{
      MessageModel msg = MessageModel.fromJson(Map<String,dynamic>.from(jsonDecode(payload)));

      await wvcApiInstance.flnApiInstance.flnPlugin.cancel(msg.msgTypeToInt);
      if(wvcApiInstance.flnApiInstance.notiListContainer.isNotEmpty) {

        wvcApiInstance.flnApiInstance.listRemoveProc(msg);
        wvcApiInstance.flnApiInstance.msgStrCnt.add("remove");
        print("온 셀렉트 : ${wvcApiInstance.flnApiInstance.notiListContainer.length}");
        // FlutterAppBadger.updateBadgeCount(
        //     wvcApiInstance.flnApiInstance.notiListContainer.length);

        /// 받은 URL,compCd 업데이트
        wvcApiInstance.receivedURL = msg.url;
        wvcApiInstance.compCd = msg.compCd;
        wvcApiInstance.compUserId = msg.userId;

        /// loginCheck 먼저하고 재로그인
        await _checkSignin(
            await wvcApiInstance.webViewPages.first.viewModel.webViewController.getUrl());

        /// 리로드 체크
        if (ScreenHolderController.to.currentIndex == 1) {
          ScreenHolderController.to.onPressHomeBtn();
        }
        if (isSignin) await checkAndReLoadUrl();
      }
    }catch(e,s){
      print(e);
      print(s);
    }

  }

  _checkSignin(String currentURL) async {
    ///로그인이후 결과인지 체크, 맞으면 로그인환영 스낵바 호출
    ///&&this.progress==-1 && !ssItem.isNull
    try{
      print(
          "ssitem : ${!wvcApiInstance.ssItem.isNull}, isSignin : ${!(isSignin)} ");
      if (!wvcApiInstance.ssItem.isNull && !isSignin) {
        wvcApiInstance.flnApiInstance.showLoginNotification();
        isSignin = true;
        ScreenHolderController.to.toggle = isSignin;
      }

      ///로그아웃하는 중인지 체크, 로그아웃하는 url이면 로그아웃절차 시작
      ///!ssItem.isNull, 로그인상태 여부 체크
      if (currentURL.endsWith("/login") && isSignin) {
        wvcApiInstance.ssItem = null;
        isSignin = false;
        ScreenHolderController.to.toggle = isSignin;
      }
    }catch(e,s){
      print(e);
      print(s);
    }
  }

  /// checkAndReLoadUrl(), fcm에서 링크가 보내지면 리로드 동작, 평소에는 URL변수가 null -> 체크후 return;
  /// fcm의 의해 새로운 링크가 추가되었는지 체크 -> 웹뷰 리로드 -> URL변수 null 초기화
  Future<void> checkAndReLoadUrl() async {
    if((wvcApiInstance.receivedURL == "/"||wvcApiInstance.receivedURL==null)||(!isSignin)) return Future<void>.value();

    if (wvcApiInstance.procType=="2") {
      String source7 = """
      try{
      document.getElementById("taxAgentKey").value="${wvcApiInstance.compCd}";
      document.getElementById("taxAgentUserId").value="${wvcApiInstance.compUserId}";
      var form = document.getElementById("bizbooksForm");
      console.log(document.getElementById("taxAgentKey").value + " : " + document.getElementById("taxAgentUserId").value);
      form.target = "_blank";
      form.method = "post";
      form.action = "/m/taxagent/m/main";
      form.taxAgentKey.value = document.getElementById('taxAgentKey').value;
      form.submit();
            }catch(e){
      console.log(e);
      }
      """;

      await wvcApiInstance.webViewPages.first.viewModel.webViewController.evaluateJavascript(source: source7);
      await wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;// ajax 결과 나온 상태

      wvcApiInstance.compCd=null;
      wvcApiInstance.compUserId=null;

    }else{
      await wvcApiInstance.webViewPages.first.viewModel.webViewController
          .loadUrl(
          url: (wvcApiInstance.receivedURL
              .endsWith("/board"))
              ? BOARD_URL
              : FILE_STORAGE_URL);
      wvcApiInstance.compCd=null;
      wvcApiInstance.compUserId=null;
      wvcApiInstance.receivedURL = null;
    }
    return Future<void>.value();
  }

  autoLoginProc() async {
    try{
      print("자동로그인 체크");
      String autoLoginProcSource = """
      var xhttp = new XMLHttpRequest();
      xhttp.open("POST", "$TOKEN_LOGIN_URL", true);
      xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      xhttp.send("devToken=${wvcApiInstance.deviceToken}");
       """;

      await wvcApiInstance.webViewPages.first.viewModel.webViewController
          .evaluateJavascript(source: autoLoginProcSource);
      await wvcApiInstance
          .ajaxApiInstance.ajaxCompleter.future; // ajax 결과 나온 상태
      wvcApiInstance.ssItem = await SessionStorage(
              wvcApiInstance.webViewPages.first.viewModel.webViewController)
          .getItem(key: "loginUserForm");
      if (wvcApiInstance.ssItem != null) {
        wvcApiInstance.procType = wvcApiInstance.ssItem["procType"].toString();
        await wvcApiInstance.webViewPages.first.viewModel.webViewController
            .loadUrl(
                url: MAIN_URL +
                    ((wvcApiInstance.ssItem["procType"] == 2)
                        ? MAIN_URL_LIST[0]
                        : MAIN_URL_LIST[1]));
      }
      await checkSignin(await wvcApiInstance
          .webViewPages.first.viewModel.webViewController
          .getUrl());
    }catch(e,s){
      print(e);
      print(s);
    }
  }

  shouldWebViewOptionChange(WebViewModel model) async {
    if(model.options.crossPlatform.useShouldInterceptAjaxRequest
        &&wvcApiInstance.procType!="2"){
      model.webViewGroupOptionSetter(false);
      await wvcApiInstance.webViewPages.first.viewModel.webViewController.setOptions(options: model.options);
      await SessionStorage(wvcApiInstance.webViewPages.first.viewModel.webViewController).setItem(key: "loginUserForm", value: wvcApiInstance.ssItem).then((value) async {
        if (wvcApiInstance.receivedURL != null) {
          await wvcApiInstance.webViewPages.first.viewModel.webViewController
              .loadUrl(
              url: (wvcApiInstance.receivedURL
                  .endsWith("/board"))
                  ? BOARD_URL
                  : FILE_STORAGE_URL);
          wvcApiInstance.receivedURL = null;
          print("돌아야지");
        }
      });
      ///일반용 리로드 여부 체크 (푸시 알람 터치후 로그인 후 온 상태인지 여부)
    }
  }
  /// TODO : Ajax 로직 여기로 이동 필요
  ajaxRequestInterceptProc(AjaxRequest ajaxRequest){
    String data = ajaxRequest.data;
    print("ajax 납치 시작 : ${ajaxRequest.url}");
    switch (ajaxRequest.url) {
      case INIT_LOGIN_URL:
        if (!data.contains("procType")) ajaxRequest.data = data + "&devToken=${wvcApiInstance.deviceToken}";
        addAjaxCompleter(ajaxRequest);
        break;
      case TOKEN_LOGIN_URL:
        if(!isError) {
          autoLoginDialog();
          addAjaxCompleter(ajaxRequest);
        }
        break;
      case LOGOUT_URL:
        addAjaxCompleter(ajaxRequest);
        break;
      default:
        break;
    }
  }

  ajaxRequestInterceptResponseProc(AjaxRequest ajaxRequest) async {
    String res = ajaxRequest.responseText;
    print("ajax 납치 끝 : ${ajaxRequest.url}");
    switch (ajaxRequest.url.toString()) {
      case TOKEN_LOGIN_URL:
        if (!res.isNullOrBlank) await SessionStorage(wvcApiInstance.webViewPages.first.viewModel.webViewController).setItem(key: "loginUserForm", value: jsonDecode(res));
        wvcApiInstance.ajaxApiInstance.ajaxLoadDone = ajaxRequest; //스트림 종료
        Get.back();
        break;
      case INIT_LOGIN_URL:
        wvcApiInstance.ssItem = await SessionStorage(wvcApiInstance.webViewPages.first.viewModel.webViewController).getItem(key: "loginUserForm");
        wvcApiInstance.procType = wvcApiInstance.ssItem["procType"].toString();
        Get.back();
        await checkSignin(await wvcApiInstance.webViewPages.first.viewModel.webViewController.getUrl());
        wvcApiInstance.ajaxApiInstance.ajaxLoadDone = ajaxRequest;
        break;
      case LOGOUT_URL:
        wvcApiInstance.ajaxApiInstance.ajaxLoadDone = ajaxRequest;
        break;
      default:
        break;
    }
  }

  ///progress 변경시 콜백
  _progressChanged(double progress) {
    this.progress = progress;
    update();
  }

  addAjaxCompleter(AjaxRequest ajaxRequest){
    wvcApiInstance.ajaxApiInstance.streamController.add(ajaxRequest);
    wvcApiInstance.ajaxApiInstance.ajaxCompleter = Completer();
  }

}