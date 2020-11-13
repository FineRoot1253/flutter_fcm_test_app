import 'dart:convert';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final screenHeight;

  const WebViewPage({Key key, @required this.screenHeight}) : super(key: key);

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
  void dispose() {
    // TODO: implement dispose
    webViewController.streamController.close();
    webViewController.ajaxStreamSubScription.cancel();
    super.dispose();
  }


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
                GetBuilder<WebViewController>(
                  builder: (_) =>
                     (webViewController.progress<1.0)
                        ? LinearProgressIndicator(
                          value: webViewController.progress.toDouble(),)
                        : Container()),
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
                          disableHorizontalScroll: true,
                          verticalScrollBarEnabled: false,
                          disableVerticalScroll: false
                    )),
                    onWebViewCreated: (InAppWebViewController controller)  {
                      webViewController.wvc = controller;
                    },
                    onProgressChanged:
                        (InAppWebViewController controller, int progress) async {
                      /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지

                      webViewController.progressChanged((progress / 100));

                    },
                    onLoadStart: (InAppWebViewController controller,
                        String url) async {
                      //URLLoad시작
                      //시작시 현 컨트롤러 업데이트 & 세션스토리지 로드 + 업데이트 -> 로그인 체크 가능
                      /// 전 url, 현재 url로 스크롤 저장여부 판단
                      print("${await webViewController.wvc.getUrl()}\n${await controller.getUrl()}\n${url}");

                      webViewController.wvc = controller;
                      // 서순에 맞게 로딩을 하기위해 future화 -> 다이얼로그가 끝나야 로그인체크를 시작
                      if(url.endsWith("/m")) autoLoginDialog();

                      SessionStorage ss =
                          SessionStorage(webViewController.wvc);
                      webViewController.ssItem =
                          await ss.getItem(key: "loginUserForm");
                      webViewController.checkSignin(url);
                      //리로드 + 체크용도
                      await webViewController.checkAndReLoadUrl();

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
                        if(!data.contains("procType")) {

                          /// TODO 다이얼로그 close
                          Get.back();
                          webViewController.tempUserForm["userId"] = data.split("&")[0].split("=")[1];
                          webViewController.tempUserForm["userPwd"] = data.split("&")[1].split("=")[1];
                          ajaxRequest.data = data + "&devToken=${webViewController.deviceToken}";
                        }else{
                          await controller.evaluateJavascript(source: """document.getElementById("m_taxagent_custlist_content_page").scrollTop)}""").then((value) async =>  print("결과 : ${await controller.getUrl()} :$value"));
                        }
                        print(
                            "수정 후 data : ${ajaxRequest.data} : ${ajaxRequest.url} : ${webViewController.tempUserForm}");
                      }
                      print(
                          "\n\n\n ajaxRequest Checking : ${ajaxRequest.toString()} \n\n\n");

                      return ajaxRequest;
                    },
                    onAjaxReadyStateChange: (InAppWebViewController controller,
                        AjaxRequest ajaxRequest) async {

                      if(ajaxRequest.url.toString().contains("loginProc")&&ajaxRequest.readyState == AjaxRequestReadyState.DONE&&ajaxRequest.status == 200) {
                        //푸시알람 터치시 프로세스 OR 자동로그인시 프로세스
                        webViewController.storeViewScrollControl(true);
                        if (webViewController.isSignin || webViewController.readUser.isNotEmpty) {
                          webViewController.ajaxLoadDone = ajaxRequest;
                          String res = ajaxRequest.responseText;
                          await SessionStorage(controller).setItem(
                              key: "loginUserForm", value: json.decode(res));
                        }
                        else{
                          // 최초 로그인시 프로세스
                          Map<String, dynamic> resTextMap = jsonDecode(ajaxRequest.responseText);
                          if(resTextMap["user"]!=null&&webViewController.readUser.isEmpty) await webViewController.storeUserLoginForm();
                        }
                      }

                      return AjaxRequestAction.PROCEED;

                    },
                    onAjaxProgress: (InAppWebViewController controller,
                        AjaxRequest ajaxRequest) async {
                      return AjaxRequestAction.PROCEED;
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      if(url.endsWith("/m")) {
                        webViewController.wvc=controller;
                        print("로딩 체크 : ${await controller.isLoading()} : ${webViewController.progress}");


                        await webViewController.autoLoginProc();
                      }
                      },
                    onScrollChanged:(InAppWebViewController controller, int x, int y){
                      print("감지 : $x : $y");
                      webViewController.storeViewScrollControl(false, x: x,y: y);

                    }

                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
