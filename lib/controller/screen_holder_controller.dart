import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/sub_web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenHodlerController extends GetxController {

  static ScreenHodlerController get to => Get.find();

  final wvcApiInstance = WVCApi();

  List<SubWebViewPage> subWebViewPages = List<SubWebViewPage>();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  double screenHeight;
  bool isSignin = false;
  int currentIndex = 0;


  set toggle(bool isSigin) {
    this.isSignin = isSigin;
    update();
  }
  set setIndexedStack(int index){
    this.currentIndex=index;
    update();
  }



  void changeWebViewModel(WebViewModel model, int index){
    wvcApiInstance.subWebViewModel=model;
    subWebViewPages.add(SubWebViewPage(screenHeight: screenHeight));
    setIndexedStack=index;
  }

  void onPressHomeBtn() async {
    if(wvcApiInstance.procType!="2") {
      await wvcApiInstance.mainWebViewModel.webViewController.loadUrl(url: MAIN_URL+MAIN_URL_LIST[1]);
      return ;
    }
    setIndexedStack=0;
    subWebViewPages.clear();
  }

}

class NotificationToggleController extends GetxController{

  static NotificationToggleController get to => Get.find();

  final wvcApiInstance = WVCApi();
  bool listCheckedOut;

  onInitiate(){
    wvcApiInstance.flnApiInstance.msgSub=wvcApiInstance.flnApiInstance.msgStream.listen((event) {
      // print(wvcApiInstance.sendPort);
      // wvcApiInstance.sendPort.send(wvcApiInstance.flnApiInstance.notiList);
      if(wvcApiInstance.flnApiInstance.notiList.length>0) drawerToggle=false;
      else drawerToggle=true;
    });
  }

  set drawerToggle(bool listCheckedOut){
    this.listCheckedOut=listCheckedOut;
    update();
  }

}