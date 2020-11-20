import 'dart:async';
import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/main_webview_controller.dart';
import 'package:fcm_tet_01_1008/screen/main_web_view_page.dart';
import 'package:fcm_tet_01_1008/screen/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenHolder extends StatefulWidget {
  @override
  _ScreenHolderState createState() => _ScreenHolderState();
}

class _ScreenHolderState extends State<ScreenHolder> {
  bool isTimerRunnting = false;

  MainWebViewController controller = MainWebViewController.to;
  ScreenHodlerController screenHodlerController = Get.put(ScreenHodlerController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: SafeArea(
        child: GetBuilder<ScreenHodlerController>(
          initState: (_){screenHodlerController.screenHeight=MediaQuery.of(context).padding.top;},
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
                  onPressed: _.onPressHomeBtn,
                ),
              ) : FloatingActionButton(backgroundColor: Colors.transparent,elevation: 0.0),
              body: IndexedStack(
                index: _.currentIndex,
                children: [
                  MainWebViewPage(screenHeight: screenHodlerController.screenHeight),
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
    if(Get.routing.route.isFirst){
      if(!isTimerRunnting){
        startTimer();
        showToast(context);
        return false;
      }else {
        return true;
      }
    }else{
      isTimerRunnting = false;
      return true;
    }
  }
  
  startTimer(){

    isTimerRunnting = true;

    var timer = Timer.periodic(Duration(seconds: 2), (time) {
      isTimerRunnting = false;
      time.cancel();
    });
  }


}

