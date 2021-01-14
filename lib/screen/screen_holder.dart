import 'dart:async';
import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/sub_webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/webview_page.dart';
import 'package:fcm_tet_01_1008/screen/widgets/drawer.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';


class ScreenHolder extends StatefulWidget {
  @override
  _ScreenHolderState createState() => _ScreenHolderState();
}

class _ScreenHolderState extends State<ScreenHolder>  with WidgetsBindingObserver{
  bool isTimerRunnting = false;

  ScreenHolderController _controller =
  Get.put(ScreenHolderController());
  NotificationToggleController drawerToggleController=Get.put(NotificationToggleController());
  NotificationDrawerController ndc = Get.put(NotificationDrawerController());
  SubWebViewController swc = Get.put(SubWebViewController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    try{_controller.wvcApiInstance.sendToIsolate(true);}catch(e,s){
      print(e);
      print(s);
    }
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state)async {
    print("현재 AppLifecycleState : $state");

    if(state == AppLifecycleState.inactive){
      print("백그라운드 이동전 저장시 길이 : ${await _controller.wvcApiInstance.spApiInstance.getList.length}");
      await _controller.wvcApiInstance.spApiInstance.setList(_controller.wvcApiInstance.flnApiInstance.notiListContainer);
      _controller.state=state;
    }
    if(state == AppLifecycleState.detached){
      await _controller.wvcApiInstance.spApiInstance.setList(_controller.wvcApiInstance.flnApiInstance.notiListContainer);
      print("종료전 메시지 send 가능성 test");
      // FlutterAppBadger.updateBadgeCount(_controller.wvcApiInstance.flnApiInstance.notiListContainer.length);
    }



    super.didChangeAppLifecycleState(state);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: GetBuilder<ScreenHolderController>(
          initState: (_) {
            _controller.screenHeight =
                MediaQuery.of(context).padding.top;
            _controller.wvcApiInstance.addWebViewPage(WebViewPage(screenHeight: _controller.screenHeight,viewModel: WebViewModel(url: MAIN_URL)));
          },
          builder: (_) {
            return Scaffold(
              key:_.key,
              drawer: NotificationDrawer(),
              resizeToAvoidBottomInset: false,
              resizeToAvoidBottomPadding: false,
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: _.isSignin
                  ? BottomAppBar(
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
                        drawerToggleController.drawerToggle=true;
                      },
                      icon: GetBuilder<NotificationToggleController>(
                        initState: (_){
                          drawerToggleController.onInitiate();
                          drawerToggleController.listCheckedOut = (_controller.wvcApiInstance.flnApiInstance.notiListContainer.length > 0) ?
                          false:
                          true;
                        },
                        builder:(_){
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
                                      style: TextStyle(fontSize: 8,color: Colors.white),
                                    ),
                                  ),
                                ))
                                : Container()
                          ]);
                        } ,
                      ),
                    ),
                  ))
                  : BottomAppBar(),
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
              body: IndexedStack(
                index: _.currentIndex,
                children: _.wvcApiInstance.webViewPages,
              ),
            );
          },
        ),
      ),
      onWillPop: _willPopCallBack,
    );
  }
//TODO : 여기
  Future<bool> _willPopCallBack() async {
    print("현재 뷰 인덱스 : ${_controller.currentIndex}");
    if(_controller.currentIndex==0) {
      if(await _controller.wvcApiInstance.webViewPages.last.viewModel.webViewController.canGoBack()){

        WebHistory wh =await _controller.wvcApiInstance.webViewPages.last.viewModel.webViewController.getCopyBackForwardList();
        if(wh.currentIndex>1) {
          await _controller.wvcApiInstance.webViewPages.last.viewModel.webViewController.goBack();
          return false;
        }
      }
    } else if(_controller.currentIndex==1){
      if(await _controller.wvcApiInstance.webViewPages.last.viewModel.webViewController.canGoBack()) {
        await SessionStorage(_controller.wvcApiInstance.webViewPages.last.viewModel.webViewController).setItem(key: "loginUserForm",value: _controller.wvcApiInstance.webViewPages.last.viewModel.ssItem);
        await _controller.wvcApiInstance.webViewPages.last.viewModel.webViewController
            .goBack();
        return false;
      } else {
        _controller.onPressHomeBtn();
        return false;
      }
    } else if(_controller.currentIndex==2) {
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
