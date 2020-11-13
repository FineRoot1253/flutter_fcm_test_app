import 'dart:async';

import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
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
  ScreenHodlerController screenHodlerController = Get.put(ScreenHodlerController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: GetBuilder<ScreenHodlerController>(
          builder:(_){
            return Scaffold(
              resizeToAvoidBottomInset: false,
              resizeToAvoidBottomPadding: false,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: _.isSignin ? BottomAppBar(
                  shape: _.isSignin ? CircularNotchedRectangle() : null,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child:Container(
                      height: (Get.height*0.05),
                      color: Colors.white
                  )
              ) : BottomAppBar(),
              floatingActionButton: _.isSignin ? Container(
                height: Get.width * 0.12,
                width: Get.width * 0.12,
                child: FloatingActionButton(
                  child:Container(
                    decoration: BoxDecoration(
                      shape:BoxShape.circle,
                      image: DecorationImage(image: Image.asset("assets/images/app_icon.png",fit: BoxFit.cover,isAntiAlias: true,).image)
                    ),
                  ),
                  onPressed: () async => await controller.wvc.scrollTo(x: 0, y: 40),
                ),
              ) : FloatingActionButton(backgroundColor: Colors.transparent,elevation: 0.0),
              body: Container(
                  child: WebViewPage(screenHeight: MediaQuery.of(context).padding.top,)
              ),
            );
          },
        ),
      ),
      onWillPop: _willPopCallBack,
    );
  }

  Future<bool> _willPopCallBack() async {
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

