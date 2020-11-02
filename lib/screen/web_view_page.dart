import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  /// 편한 컨트롤러 접근을 위해 추가, to 생략 가능
  WebViewController webViewController = WebViewController.to;

  @override
  void initState() {
    // TODO: implement initState
    webViewController.initNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(Get.routing.route.settings.name);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetBuilder<WebViewController>(
                    builder: (_){

                      return (webViewController.progress<1.0)
                          ? LinearProgressIndicator(
                            value: webViewController.progress.toDouble(),)
                          : Container();
                    },
                  ),
                  // (webViewController.progress>0)
                  //     ? Container(
                  //       child: LinearProgressIndicator(
                  //   value: webViewController.progress,),
                  //     )
                  //     : Container(),
                  // Container(
                  //   padding: EdgeInsets.all(10.0),
                  //   child: (webViewController.progress>0)
                  //       ? LinearProgressIndicator(
                  //     value: webViewController.progress,)
                  //       : Container()
                  // ),
                  Expanded(
                    child: InAppWebView(
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                      initialUrl: MAIN_URL,
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                        clearCache: true,
                        debuggingEnabled: true,
                        useShouldOverrideUrlLoading: true,
                        useShouldInterceptAjaxRequest: true,
                      )),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webViewController.wvc = controller;
                      },
                      onProgressChanged:
                          (InAppWebViewController controller, int progress) {
                        /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지

                        webViewController.progressChanged((progress / 100));
                      },
                      onLoadStart: (InAppWebViewController controller,
                          String url) async {
                        //URLLoad시작
                        //시작시 현 컨트롤러 업데이트 & 세션스토리지 로드 + 업데이트 -> 로그인 체크 가능
                        webViewController.wvc = controller;
                        // 서순에 맞게 로딩을 하기위해 future화 -> 다이얼로그가 끝나야 로그인체크를 시작

                        SessionStorage ss =
                            SessionStorage(webViewController.wvc);
                        webViewController.ssItem =
                            await ss.getItem(key: "loginUserForm");
                        webViewController.checkSignin(url);

                        //리로드 + 체크용도
                        await webViewController.checkAndReLoadUrl();
                        print("로딩 끝");
                      },
                      shouldOverrideUrlLoading:
                          (controller, shouldOverrideUrlLoadingRequest) async {
                        var url = shouldOverrideUrlLoadingRequest.url;
                        var uri = Uri.parse(url);
                        print("오버로딩 URL 체크 : $url");
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
                        if (ajaxRequest.method == "POST" &&
                            ajaxRequest.url == "/bizbooks/login/loginProc") {
                          print(
                              "\n\n\n인터셉트 완료 : ${ajaxRequest.toString()} \n\n\n");
                          String data = ajaxRequest.data;
                          ajaxRequest.data = data +
                              "&devToken=${webViewController.deviceToken}";
                          print(
                              "수정 후 data : ${ajaxRequest.data} : ${ajaxRequest.url}");
                        }
                        print(
                            "\n\n\n ajaxRequest Checking : ${ajaxRequest.toString()} \n\n\n");

                        return ajaxRequest;
                      },
                      onAjaxProgress: (InAppWebViewController controller,
                          AjaxRequest ajaxRequest) async {
                        /// TODO: 1029  여기서 인터셉트 처리하게 수정
                        if (ajaxRequest.event.type ==
                            AjaxRequestEventType.LOAD) {
                          Map<String, Object> res = ajaxRequest.response;
                        }
                        return AjaxRequestAction.PROCEED;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
