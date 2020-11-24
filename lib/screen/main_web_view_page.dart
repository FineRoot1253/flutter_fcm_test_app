import 'dart:async';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/main_webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class MainWebViewPage extends StatefulWidget {
  final screenHeight;

  const MainWebViewPage({Key key, @required this.screenHeight})
      : super(key: key);

  @override
  _MainWebViewPageState createState() => _MainWebViewPageState();
}

class _MainWebViewPageState extends State<MainWebViewPage> {
  /// 편한 컨트롤러 접근을 위해 추가, to 생략 가능
  MainWebViewController _controller = MainWebViewController.to;
  Future result;

  @override
  void initState() {
    // TODO: implement initState
    result = _controller.initNotifications();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.wvcApiInstance.ajaxApiInstance.streamController.close();
    _controller.wvcApiInstance.ajaxApiInstance.ajaxStreamSubScription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        height: Get.height - (widget.screenHeight + Get.height * 0.05),
        width: Get.width,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GetBuilder<MainWebViewController>(
                  builder: (_) => (_controller.progress < 1.0)
                      ? LinearProgressIndicator(
                          value: _controller.progress.toDouble(),
                        )
                      : Container()),
              Expanded(
                child: FutureBuilder(
                  future: result,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return buildWebView();
                    else if (snapshot.hasError)
                      return Text("오류가 발생하여 접근이 불가합니다.");
                    else
                      return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildWebView() {
    return InAppWebView(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      initialUrl: MAIN_URL,
      initialOptions: _controller.webViewGroupOptions,
      onWebViewCreated: (InAppWebViewController controller) {
        _controller.wvcApiInstance.mainWebViewModel.webViewController =
            controller;
      },
      onProgressChanged:
          (InAppWebViewController controller, int progress) async {
        /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지
        _controller.progressChanged((progress / 100));
      },
      /// 웹 페이지 완전 로드 체크를 위해 필요
      /// 로드 이후 연산을 담당
      /// 수임 업체 리스트를 완전 로드시 리로드 체크
      onLoadResource: (controller, resource) async {
        /// TODO : resource.url 분기 세분화 필요!
        _controller.wvcApiInstance.mainWebViewModel.webViewController=controller;
        /// 관제용리로드 여부 체크(푸시알람 터치후 로그인 하고 온 상태인지 여부)
        if (resource.url.contains("/selectCustlist")) {
          String currentUrl = await controller.getUrl();
          if (currentUrl.contains(MAIN_URL_LIST[0])) await _controller.checkAndReLoadUrl();
        }

        if (resource.url.contains("/m_header.js")) {
          String currentUrl = await controller.getUrl();

          ///관제용 메인(수임업체리스트)에서 initlogout
          if(currentUrl.contains(MAIN_URL_LIST[0])) await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[0]);

          if(currentUrl.contains(MAIN_URL_LIST[1])){

            /// 일반용 메인(대시보드)에서 ajaxoption false화
            await _controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future; // ssItem 업데이트까지 임시 대기
            _controller.shouldWebViewOptionChange();

            ///일반용 리스트에서 initlogout
            await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[1]);
          }
        }
      },
      /// onloadStart, onLoadStop -> 자동로그인(토큰로그인)만 담당
      onLoadStart: (InAppWebViewController controller, String url) async {
        //URLLoad시작
        //시작시 현 컨트롤러 업데이트 & 세션스토리지 로드 + 업데이트 -> 로그인 체크 가능
        _controller.wvcApiInstance.mainWebViewModel.webViewController =
            controller;
        if (url.endsWith("/m")) autoLoginDialog(); //최초 로그인시 다이얼로그 호출
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        _controller.wvcApiInstance.mainWebViewModel.webViewController =
            controller;
        if (url.endsWith("/m")) await _controller.autoLoginProc();
        //리로드 + 체크용도
      },
      /// 전화번호 링크 체크 + 게시판 뒤로가기 오버로드 체크
      shouldOverrideUrlLoading:
          (controller, shouldOverrideUrlLoadingRequest) async {
        var url = shouldOverrideUrlLoadingRequest.url;
        var uri = Uri.parse(url);
        print("오버로딩 체크 : $url");
        if (["tel"].contains(uri.scheme)) {
          if (await canLaunch(url)) await launch(url);
          return ShouldOverrideUrlLoadingAction.CANCEL;
        }
        if (url.endsWith("/board/detail?no=undefined&bc=undefined")) return ShouldOverrideUrlLoadingAction.CANCEL;


        return ShouldOverrideUrlLoadingAction.ALLOW;
        // 만약 강제로 리다이렉트, 등등을 원할 경우 여기서 url 편집
      },
      /// 로그인 관련 ajaxRequest담당
      /// 최초 로그인시 토큰 추가
      /// 토큰 로그인(자동 로그인)시 세션 스토리지 set
      /// TODO : 로그아웃은 삭제 필요
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        String data = ajaxRequest.data;

        if (ajaxRequest.method == "POST"&&!data.contains("procType")) _controller.ajaxRequestInterceptProc(ajaxRequest);

        return ajaxRequest;
      },
      /// 로그인 ajaxRequest Result 로직
      /// 최초 로그인시 ssItem 업데이트
      /// 토큰 로그인(자동 로그인)시 세션 스토리지 업데이트
      onAjaxReadyStateChange:
          (InAppWebViewController controller, AjaxRequest ajaxRequest) async {

        _controller.wvcApiInstance.mainWebViewModel.webViewController=controller;

        if (ajaxRequest.method == "POST" &&
            ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
            ajaxRequest.status == 200) await _controller.ajaxRequestInterceptResponseProc(ajaxRequest);

        return AjaxRequestAction.PROCEED;
      },
      /// 로그아웃 버튼 클릭 체크용
      /// 로그아웃시 로그아웃 proc 호출
      /// 로그아웃시 procType에 따라 웹뷰 재설정, ajaxoptions false -> true
      onConsoleMessage: (controller, consoleMessage) async {
        print("콘솔 로그 : ${consoleMessage.message}");
        if (consoleMessage.message == "logout"){
          await _controller.wvcApiInstance.logoutProc();
          if(_controller.wvcApiInstance.procType!="2"){
            _controller.webViewGroupOptionSetter(true);
            await controller.setOptions(options: _controller.webViewGroupOptions);
          }
        }

      },
      /// 대시보드등등 새탭이 열리는 동작을 담당
      onCreateWindow: (controller, createWindowRequest) async {
        ScreenHodlerController.to.changeWebViewModel(
            WebViewModel(
                url: "about:blank", windowId: createWindowRequest.windowId),
            1);
        return true;
      },
    );
  }
}
