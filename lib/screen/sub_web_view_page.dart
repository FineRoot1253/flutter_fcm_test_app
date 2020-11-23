import 'dart:async';

import 'package:fcm_tet_01_1008/controller/main_webview_controller.dart';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/sub_webview_controller.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class SubWebViewPage extends StatefulWidget {
  final screenHeight;
  const SubWebViewPage({Key key, @required this.screenHeight}) : super(key: key);

  @override
  _SubWebViewPageState createState() => _SubWebViewPageState();
}

class _SubWebViewPageState extends State<SubWebViewPage> {

  SubWebViewController _controller = SubWebViewController.to;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        height: Get.height-(widget.screenHeight+Get.height*0.05),
        width: Get.width,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GetBuilder<MainWebViewController>(
                  builder: (_) =>
                  (_.progress<1.0)
                      ? LinearProgressIndicator(
                    value: _.progress.toDouble(),)
                      : Container()),
              Expanded(
                child: buildSubWebView()
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildSubWebView(){
    return InAppWebView(
      gestureRecognizers:
      <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      initialUrl: _controller.wvcApiInstance.subWebViewModel.url,
      windowId: _controller.wvcApiInstance.subWebViewModel.windowId,
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true,
          ),
          crossPlatform: InAppWebViewOptions(
              javaScriptCanOpenWindowsAutomatically: true,
            clearCache: true,
            debuggingEnabled: true,
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
          )),
      onWebViewCreated: (InAppWebViewController controller)  {
        _controller.wvcApiInstance.subWebViewModel.webViewController = controller;
      },
      onLoadResource: (controller, resource) async {
        /// TODO : resource.url 분기 세분화 필요!
        print(resource.url);
        if(resource.url.contains("/m_header.js")){
          await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[1]);
        }
      },
      onAjaxProgress: (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
        return AjaxRequestAction.PROCEED;
      },
      onProgressChanged:
          (InAppWebViewController controller, int progress) async {
        /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지
        MainWebViewController.to.progressChanged((progress / 100));
      },
      onLoadStart: (InAppWebViewController controller,
          String url) async {
        //URLLoad시작
        _controller.wvcApiInstance.subWebViewModel.webViewController = controller;
        if(url.endsWith("/login")) ScreenHodlerController.to.onPressHomeBtn();
      },
      shouldOverrideUrlLoading:
          (controller, shouldOverrideUrlLoadingRequest) async {
        var url = shouldOverrideUrlLoadingRequest.url;
        var uri = Uri.parse(url);
        print("오버로딩 URL 체크 : $url");
        if(url.endsWith("no=undefined&bc=undefined")) {
          // controller.goBack();
          return ShouldOverrideUrlLoadingAction.CANCEL;
        }

        return ShouldOverrideUrlLoadingAction.ALLOW;
        // 만약 강제로 리다이렉트, 등등을 원할 경우 여기서 url 편집
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        if(url.endsWith("/dashboard")&&_controller.wvcApiInstance.receivedURL!=null){
          await _controller.wvcApiInstance.subWebViewModel.webViewController.loadUrl(url:(_controller.wvcApiInstance.receivedURL.endsWith("/board")) ? BOARD_URL : FILE_STORAGE_URL);
          _controller.wvcApiInstance.receivedURL = null;
        }
        print("현재 히스토리 : ${await controller.getCopyBackForwardList()}");
        //리로드 + 체크용도
      },
      onConsoleMessage: (controller, consoleMessage) async {
        print("콘솔 로그 : ${consoleMessage.message}");
        if(consoleMessage.message=="logout") ScreenHodlerController.to.onPressHomeBtn();
      },
    );
  }
}
