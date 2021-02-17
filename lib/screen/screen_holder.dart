import 'dart:async';
import 'dart:io';
import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/webview_page.dart';
import 'package:fcm_tet_01_1008/screen/widgets/drawer.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';

class ScreenHolder extends StatefulWidget {
  @override
  _ScreenHolderState createState() => _ScreenHolderState();
}

class _ScreenHolderState extends State<ScreenHolder>
    with WidgetsBindingObserver {
  bool isTimerRunnting = false;

  ScreenHolderController _controller = Get.put(ScreenHolderController());
  NotificationToggleController drawerToggleController =
      Get.put(NotificationToggleController());
  NotificationDrawerController ndc = Get.put(NotificationDrawerController());
  WebViewController wbc = Get.put(WebViewController());
  Future result;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    result = _controller.wvcApiInstance.flnApiInstance
        .initNotificationListContainer();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("현재 AppLifecycleState : $state");

    if (state == AppLifecycleState.resumed) {
      await _controller.wvcApiInstance.flnApiInstance
          .initNotificationListContainer();
      _controller.wvcApiInstance.flnApiInstance.msgStrCnt.add("reset");
    }

    /// isolate간 메모리가 다르니 인스턴스도 다르다는 것을 늘 염두 할 것
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused||state == AppLifecycleState.detached)
      await _controller.wvcApiInstance.daoIns.closeBox();

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: result,
        builder: (context, snapshot) {
          if (snapshot.hasData) return buildScreenHold();
          if (snapshot.hasError)
            return Center(child: Text("Error!\n${snapshot.error.toString()}"));
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget buildScreenHold() {
    return WillPopScope(
      child: GetBuilder<ScreenHolderController>(
        initState: (_) {
          _controller.screenHeight = (Platform.isAndroid)
              ? MediaQuery.of(context).padding.top
              : MediaQuery.of(context).viewPadding.top;
          _controller.wvcApiInstance.addWebViewPage(WebViewPage(
              screenHeight: _controller.screenHeight,
              viewModel: WebViewModel(url: MAIN_URL)));
        },
        builder: (_) {
          return Scaffold(
            key: _.key,
            drawer: NotificationDrawer(),
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
                shape: _.isSignin ? CircularNotchedRectangle() : null,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  height: (Get.height * 0.05),
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10.0),
                  child: IconButton(
                    color: Colors.black,
                    disabledColor: Colors.black54,
                    onPressed: () {
                      _.key.currentState.openDrawer();
                      drawerToggleController.drawerToggle = true;
                    },
                    icon: GetBuilder<NotificationToggleController>(
                      initState: (_) {
                        drawerToggleController.onInitiate();
                        print(
                            "notiListContainer 길이 : ${_controller.wvcApiInstance.flnApiInstance.notiListContainer.length}");
                        _controller
                            .wvcApiInstance.flnApiInstance.notiListContainer
                            .forEach((element) =>
                                print(element.toMap().toString()));
                        drawerToggleController.listCheckedOut = (_controller
                                    .wvcApiInstance
                                    .flnApiInstance
                                    .notiListContainer
                                    .length >
                                0)
                            ? false
                            : true;
                      },
                      builder: (_) {
                        return Stack(children: [
                          Icon(Icons.notifications),
                          (!(_.listCheckedOut))
                              ? Positioned(
                                  right: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(2.0),
                                      child: Text(
                                        "${_controller.wvcApiInstance.flnApiInstance.notiListContainer.length}",
                                        style: TextStyle(
                                            fontSize: 8, color: Colors.white),
                                      ),
                                    ),
                                  ))
                              : Container()
                        ]);
                      },
                    ),
                  ),
                )),
            floatingActionButton: _.isSignin
                ? Container(
                    height: Get.width * 0.12,
                    width: Get.width * 0.12,
                    child: FloatingActionButton(
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: Image.asset(
                              "assets/images/app_icon.png",
                              fit: BoxFit.cover,
                              isAntiAlias: true,
                            ).image)),
                      ),
                      onPressed: _.onPressHomeBtn,
                    ),
                  )
                : FloatingActionButton(
                    backgroundColor: Colors.transparent, elevation: 0.0),
            body: SafeArea(
              top: true,
              child: IndexedStack(
                index: _.currentIndex,
                children: _.wvcApiInstance.webViewPages,
              ),
            ),
          );
        },
      ),
      onWillPop: _willPopCallBack,
    );
  }

//TODO : 여기
  Future<bool> _willPopCallBack() async {
    print("현재 뷰 인덱스 : ${_controller.currentIndex}");
    if (_controller.currentIndex == 0) {
      if (await _controller
          .wvcApiInstance.webViewPages.last.viewModel.webViewController
          .canGoBack()) {
        WebHistory wh = await _controller
            .wvcApiInstance.webViewPages.last.viewModel.webViewController
            .getCopyBackForwardList();
        if (wh.currentIndex > 1) {
          await _controller
              .wvcApiInstance.webViewPages.last.viewModel.webViewController
              .goBack();
          return false;
        }
      }
    } else if (_controller.currentIndex == 1) {
      if (await _controller
          .wvcApiInstance.webViewPages.last.viewModel.webViewController
          .canGoBack()) {
        await SessionStorage(_controller
                .wvcApiInstance.webViewPages.last.viewModel.webViewController)
            .setItem(
                key: "loginUserForm",
                value: _controller
                    .wvcApiInstance.webViewPages.last.viewModel.ssItem);
        await _controller
            .wvcApiInstance.webViewPages.last.viewModel.webViewController
            .goBack();
        return false;
      } else {
        _controller.onPressHomeBtn();
        return false;
      }
    } else if (_controller.currentIndex == 2) {
      _controller.onFileurl();
      return false;
    } else {
      _controller.onPressHomeBtn();
      return false;
    }
    if (Get.routing.route.isFirst) {
      if (!isTimerRunnting) {
        startTimer();
        showToast(context);
        return false;
      } else {
        return true;
      }
    } else {
      isTimerRunnting = false;
      return true;
    }
  }

  startTimer() {
    isTimerRunnting = true;

    var timer = Timer.periodic(Duration(seconds: 2), (time) {
      isTimerRunnting = false;
      time.cancel();
    });
  }
}
