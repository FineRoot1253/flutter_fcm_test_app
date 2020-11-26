import 'dart:async';
import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/sub_webview_controller.dart';
import 'package:fcm_tet_01_1008/screen/main_web_view_page.dart';
import 'package:fcm_tet_01_1008/screen/widgets/drawer.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenHolder extends StatefulWidget {
  @override
  _ScreenHolderState createState() => _ScreenHolderState();
}

class _ScreenHolderState extends State<ScreenHolder>  with WidgetsBindingObserver{
  bool isTimerRunnting = false;

  ScreenHodlerController _controller =
      Get.put(ScreenHodlerController());
  NotificationToggleController drawerToggleController=Get.put(NotificationToggleController());
  NotificationDrawerController ndc = Get.put(NotificationDrawerController());
  SubWebViewController swc = Get.put(SubWebViewController());

  @override
  void initState() {
    // TODO: implement initState
  WidgetsBinding.instance.addObserver(this);
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
    // TODO: implement didChangeAppLifecycleState
    // print("현재 APP LIFE CYCLE : $state");

    if(state == AppLifecycleState.inactive){
      print("현재 APP LIFE CYCLE : ${_controller.wvcApiInstance.flnApiInstance.notiList}");
     await _controller.wvcApiInstance.box.put("notiList",_controller.wvcApiInstance.flnApiInstance.notiList);
    }
    super.didChangeAppLifecycleState(state);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: GetBuilder<ScreenHodlerController>(
          initState: (_) {
            _controller.screenHeight =
                MediaQuery.of(context).padding.top;
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
                              drawerToggleController.listCheckedOut = (_controller.wvcApiInstance.flnApiInstance.notiList.length > 0) ?
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
                                          "${_controller.wvcApiInstance.flnApiInstance.notiList.length}",
                                          style: TextStyle(fontSize: 8),
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
                children: [
                  MainWebViewPage(
                      screenHeight: _controller.screenHeight),
                  ..._.subWebViewPages
                ],
              ),
            );
          },
        ),
      ),
      onWillPop: _willPopCallBack,
    );
  }

  Future<bool> _willPopCallBack() async {
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
