import 'dart:async';
import 'dart:convert';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/sub_webview_controller.dart';
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
                  builder: (context, snapshot){
                    if(snapshot.connectionState==ConnectionState.done) return buildWebView();
                    else if(snapshot.hasError) return Text("오류가 발생하여 접근이 불가합니다.");
                    else return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildWebView(){
    return InAppWebView(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      initialUrl: MAIN_URL,
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
              supportMultipleWindows: true
          ),
          crossPlatform: InAppWebViewOptions(
            javaScriptCanOpenWindowsAutomatically: true,
            clearCache: true,
            debuggingEnabled: true,
            useShouldOverrideUrlLoading: true,
            useShouldInterceptAjaxRequest: true,
            useOnLoadResource: true
          )),
      onWebViewCreated: (InAppWebViewController controller) {
        _controller.wvcApiInstance.mainWebViewModel.webViewController = controller;
      },
      onProgressChanged:
          (InAppWebViewController controller, int progress) async {
        /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지
        _controller.progressChanged((progress / 100));
      },
      onLoadResource: (controller, resource) async {
        /// TODO : resource.url 분기 세분화 필요!

        if(resource.url.contains("/selectCustlist"))  {
          String currentUrl = await controller.getUrl();
          if(currentUrl.contains(MAIN_URL_LIST[0])||currentUrl.contains(MAIN_URL_LIST[1])) await _controller.checkAndReLoadUrl();
        }
        if(resource.url.contains("/m_header.js")){
          String currentUrl = await controller.getUrl();
          (currentUrl.contains(MAIN_URL_LIST[0])) ?
          await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[0]) :
          await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[1]);
        }
      },
      onLoadStart:
          (InAppWebViewController controller, String url) async {
        //URLLoad시작
        //시작시 현 컨트롤러 업데이트 & 세션스토리지 로드 + 업데이트 -> 로그인 체크 가능
        _controller.wvcApiInstance.mainWebViewModel.webViewController = controller;
        if (url.endsWith("/m")) autoLoginDialog();//최초 로그인시 다이얼로그 호출
      },
      onLoadStop:
          (InAppWebViewController controller, String url) async {

            _controller.wvcApiInstance.mainWebViewModel.webViewController = controller;

        if (url.endsWith("/m")) await _controller.autoLoginProc();
        if(url.endsWith("/dashboard")&&!(_controller.wvcApiInstance.receivedURL.isNull)){
          await _controller.wvcApiInstance.mainWebViewModel.webViewController.loadUrl(url:(_controller.wvcApiInstance.receivedURL.endsWith("/board")) ? BOARD_URL : FILE_STORAGE_URL);
          _controller.wvcApiInstance.receivedURL = null;
        }

        //리로드 + 체크용도
      },
      shouldOverrideUrlLoading:
          (controller, shouldOverrideUrlLoadingRequest) async {
        var url = shouldOverrideUrlLoadingRequest.url;
        var uri = Uri.parse(url);
        if (["tel"].contains(uri.scheme)) {
          if (await canLaunch(url)) await launch(url);
          return ShouldOverrideUrlLoadingAction.CANCEL;
        }

        return ShouldOverrideUrlLoadingAction.ALLOW;
        // 만약 강제로 리다이렉트, 등등을 원할 경우 여기서 url 편집
      },
      shouldInterceptAjaxRequest:
          (InAppWebViewController controller,
          AjaxRequest ajaxRequest) async {
        if (ajaxRequest.method == "POST") {
          String data = ajaxRequest.data;
          switch(ajaxRequest.url){
            case INIT_LOGIN_URL:
              if (!data.contains("procType")) ajaxRequest.data = data + "&devToken=${_controller.wvcApiInstance.deviceToken}";
              break;
            case TOKEN_LOGIN_URL:
            case LOGOUT_URL:
              _controller.wvcApiInstance.ajaxApiInstance.streamController.add(ajaxRequest);
              _controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter=Completer();
              break;
          }
        }
        return ajaxRequest;
      },
      onAjaxReadyStateChange: (InAppWebViewController controller,
          AjaxRequest ajaxRequest) async {
        if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
            ajaxRequest.status == 200) {
          String res = ajaxRequest.responseText;
          switch(ajaxRequest.url.toString()){
            case TOKEN_LOGIN_URL:
                if(!res.isNullOrBlank)await SessionStorage(controller).setItem(key: "loginUserForm", value: jsonDecode(res));
                _controller.wvcApiInstance.ajaxApiInstance.ajaxLoadDone = ajaxRequest;//스트림 종료
              Get.back();
              break;
            case INIT_LOGIN_URL:
              _controller.wvcApiInstance.ssItem = await SessionStorage(controller).getItem(key: "loginUserForm");
              Get.back();
              await _controller.checkSignin(await _controller.wvcApiInstance.mainWebViewModel.webViewController.getUrl());
              break;
            case LOGOUT_URL: /// TODO : 추가 조작사항이 있으면 여기서
              _controller.wvcApiInstance.ajaxApiInstance.ajaxLoadDone = ajaxRequest;
              break;
          }
        }
        return AjaxRequestAction.PROCEED;
      },
      onConsoleMessage: (controller, consoleMessage) async {
        print("콘솔 로그 : ${consoleMessage.message}");
        if(consoleMessage.message=="logout") await _controller.wvcApiInstance.logoutProc();
      },
      onCreateWindow: (controller, createWindowRequest) async {
        // TODO : 여기에서 새 윈도우를 만들어주어야한다.
        /// 화면 교체 작업을 해야한다
        ScreenHodlerController.to.changeWebViewModel(WebViewModel(url:"about:blank",windowId: createWindowRequest.windowId), 1);
        return true;
      },
    );
  }
}
