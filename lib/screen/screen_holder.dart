import 'dart:async';

import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenHolder extends StatefulWidget {
  @override
  _ScreenHolderState createState() => _ScreenHolderState();
}

class _ScreenHolderState extends State<ScreenHolder> {
  bool isTimerRunnting = false;
  WebViewController controller = WebViewController.to;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            resizeToAvoidBottomPadding: false,
          body: Container(
              child: WebViewPage(screenHeight: MediaQuery.of(context).padding.top,)
          ),
        ),
      ),
      onWillPop: _willPopCallBack,
    );
  }

  Future<bool> _willPopCallBack() async {
    print("실행은 하나요? : ${Get.routing.route.isFirst}");
    if(Get.routing.route.isFirst){
      print("1");
      if(!isTimerRunnting){
        print("2");
        startTimer();
        showToast(context);
        print("3");
        return false;
      }else {
        print("4");
        shouldLogout();
        return true;
      }
    }else{
      print("5");
      isTimerRunnting = false;
      shouldLogout();
      return true;
    }
  }

  shouldLogout()async{
    controller.ssItem.clear();
    await controller.wvc.webStorage.sessionStorage.clear();
    print("로그아웃 결과 : ${controller.ssItem} : ${await controller.wvc.webStorage.sessionStorage.getItem(key: "loginUserForm")}");
  }
  
  startTimer(){

    isTimerRunnting = true;

    var timer = Timer.periodic(Duration(seconds: 2), (time) {
      isTimerRunnting = false;
      time.cancel();
    });
  }


}

