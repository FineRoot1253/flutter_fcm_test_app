import 'dart:io';

import 'package:fcm_tet_01_1008/controller/main_webview_controller.dart';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/sub_webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/screen_holder_controller.dart';

class SubWebViewPage extends StatefulWidget {
  final screenHeight;

  const SubWebViewPage({Key key, @required this.screenHeight})
      : super(key: key);

  @override
  _SubWebViewPageState createState() => _SubWebViewPageState();
}

class _SubWebViewPageState extends State<SubWebViewPage> {
  SubWebViewController _controller = SubWebViewController.to;
  final GlobalKey<ScaffoldState> snackBarKey = GlobalKey<ScaffoldState>();
  bool _isCheckOut = false;

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
                  builder: (_) => (_.progress < 1.0)
                      ? LinearProgressIndicator(
                          value: _.progress.toDouble(),
                        )
                      : Container()),
              Expanded(child: buildSubWebView()),
            ],
          ),
        ),
      ),
    );
  }

  buildSubWebView() {
    return InAppWebView(
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      initialUrl: _controller.wvcApiInstance.subWebViewModel[_controller.shController.currentIndex-1].url,
      windowId: _controller.wvcApiInstance.subWebViewModel[_controller.shController.currentIndex-1].windowId,
      initialOptions: InAppWebViewGroupOptions(
          android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true,
          ),
          crossPlatform: InAppWebViewOptions(
            horizontalScrollBarEnabled: false,
            verticalScrollBarEnabled: false,
            useOnDownloadStart: true,
            javaScriptCanOpenWindowsAutomatically: true,
            clearCache: true,
            debuggingEnabled: true,
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
          )),
      onWebViewCreated: (InAppWebViewController controller) async {
        _controller.wvcApiInstance.subWebViewModel[_controller.shController.currentIndex-1].webViewController =
            controller;
      },
      onLoadResource: (controller, resource) async {
        if (resource.url.contains("/m_heaer.js")) {
          await _controller.wvcApiInstance.initLogoutProc(INIT_LOGOUT_BTNS[1]);
        }
      },
      onProgressChanged:
          (InAppWebViewController controller, int progress) async {
        /// webViewController.isLoadDone은 다이얼로그 중복 Get.back() 을 방지
        MainWebViewController.to.progressChanged((progress / 100));
      },
      onLoadStart: (InAppWebViewController controller, String url) async {
        _controller.wvcApiInstance.subWebViewModel[_controller.shController.currentIndex-1].webViewController =
            controller;
        if (url.endsWith("/login")) ScreenHodlerController.to.onPressHomeBtn();
      },
      onDownloadStart: (controller, url) async {
        if (_isCheckOut) {
          _isCheckOut = false;
          return;
        }
        bool isStartSnkOpen = true;
        var uri = Uri.parse(url);
        String path = uri.path;
        String fileName = path.substring(path.lastIndexOf("/") + 1);
        ScreenHodlerController.to.key.currentState
            .showSnackBar(SnackBar(
              content: Container(
                height: Get.height * 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('다운로드 시작'),
                    Text('${(fileName.length>20)? fileName.substring(0,5)+"..."+fileName.substring(fileName.lastIndexOf(".")-3,fileName.length):fileName}'),
                  ],
                ),
              ),
              duration: Duration(seconds: 3),
            ))
            .closed
            .then((value) => isStartSnkOpen = false);

        // Get.showSnackbar(GetBar(title: "다운로드 시작",message: "$fileName",key: _controller.snackKey,)).then((value) => isStartSnkOpen=false);
        var taskId = await FlutterDownloader.enqueue(
                url: url,
                fileName: fileName,
                savedDir: (await getExternalStorageDirectory()).path,
                showNotification: true,
                openFileFromNotification: true)
            .then((value) {
          print("테스트1");
          if (isStartSnkOpen) {
            print("테스트2");
            ScreenHodlerController.to.key.currentState.removeCurrentSnackBar();
          }
        });
        ScreenHodlerController.to.key.currentState.showSnackBar(SnackBar(
          content: Container(
            height: Get.height*0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('다운로드 완료'),
                Padding(padding: EdgeInsets.symmetric(vertical: 10.0),),
                Text('${(fileName.length>20)? fileName.substring(0,5)+"..."+fileName.substring(fileName.lastIndexOf(".")-3,fileName.length):fileName}'),
              ],
            ),
          ),
          action: SnackBarAction(
              label: "확인",
              onPressed: () async {
                File f = File(((await getExternalStorageDirectory()).path +
                    "/" +
                    fileName));
                print("파일 길이 : ${await f.length()} : ${f.path}");

                Uri _uri = Uri.file(f.path);
                String url =
                    "/sdcard/Android/data/com.example.fcm_tet_01_1008/files/" +
                        fileName;

                await OpenFile.open(url);
                ScreenHodlerController.to.key.currentState
                    .removeCurrentSnackBar();
              }),
        ));
        ScreenHodlerController.to.onFileurl();
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        ///
        if(url.endsWith("/dashboard")){
          if (_controller.wvcApiInstance.receivedURL != null) {
            await _controller.wvcApiInstance.subWebViewModel[_controller.shController.currentIndex-1].webViewController
                .loadUrl(
                url: (_controller.wvcApiInstance.receivedURL
                    .endsWith("/board"))
                    ? BOARD_URL
                    : FILE_STORAGE_URL);
            _controller.wvcApiInstance.receivedURL = null;
          }
          if(ScreenHodlerController.to.currentIndex==1&&_controller.wvcApiInstance.subWebViewModel[0].ssItem.isNullOrBlank) {
            _controller.wvcApiInstance.subWebViewModel[0].ssItem =
            await SessionStorage(controller).getItem(key: "loginUserForm");
          }
        }


        print("현재 sub히스토리 로그 : ${ScreenHodlerController.to.currentIndex} : ${await controller.getCopyBackForwardList()}");
      },
      shouldOverrideUrlLoading:
          (controller, shouldOverrideUrlLoadingRequest) async {
        var url = shouldOverrideUrlLoadingRequest.url;
        var uri = Uri.parse(url);
        print("오버로딩 체크 : $url");
        if (url.endsWith("no=undefined&bc=undefined"))
          return ShouldOverrideUrlLoadingAction.CANCEL;

        if (url.endsWith(".pdf")) {
          var resultCheck = await Get.defaultDialog(
            title: "파일",
            content: Text("저장 하시겠습니까?"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    if (await canLaunch(url)) {
                      _isCheckOut = true;
                      await launch(url);
                      ScreenHodlerController.to.onFileurl();
                      return Get.back(result: true);
                    }
                  },
                  child: Text("보기")),
              FlatButton(
                  onPressed: () async {
                    return Get.back(result: false);
                    // Get.defaultDialog(title: "다운로드")
                  },
                  child: Text("저장"))
            ],
          );
          if(resultCheck==null){
            _isCheckOut = true;
            ScreenHodlerController.to.onFileurl();
          }

        }

        return ShouldOverrideUrlLoadingAction.ALLOW;
        // 만약 강제로 리다이렉트, 등등을 원할 경우 여기서 url 편집
      },
      onConsoleMessage: (controller, consoleMessage) async {
        print("콘솔 로그 : ${consoleMessage.message}");
        if (consoleMessage.message == "logout")
          ScreenHodlerController.to.onPressHomeBtn();
      },
      onCreateWindow: (controller, createWindowRequest) async {
        ScreenHodlerController.to.changeWebViewModel(
            WebViewModel(
                url: "about:blank", windowId: createWindowRequest.windowId),
            2);
        return true;
      },
      onLoadError: (controller, url, code, message) async {
        if (Platform.isIOS && code == -999) {
          // NSURLErrorDomain
          return;
        }
        Get.back();
        Get.defaultDialog(
            title: "에러발생", middleText: "페이지 로드를 실패했습니다. 잠시후 시도해주세요.");
      },
    );
  }
}
