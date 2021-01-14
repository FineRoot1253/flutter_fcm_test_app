import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/web_view_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/screen/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenHolderController extends GetxController {

  static ScreenHolderController get to => Get.find();

  final wvcApiInstance = WVCApi();

  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  double screenHeight;
  bool isSignin = false;
  int currentIndex = 0;
  AppLifecycleState state;


  set toggle(bool isSigin) {
    this.isSignin = isSigin;
    update();
  }
  set setIndexedStack(int index){
    this.currentIndex=index;
    update();
  }



  void changeWebViewModel(WebViewModel model){
    wvcApiInstance.addWebViewPage(WebViewPage(screenHeight: screenHeight, viewModel: model));
    setIndexedStack=currentIndex+1;
  }

  void onPressHomeBtn() async {
    if (wvcApiInstance.procType != "2") {
      await WebViewController.to.webViewGroupOptionSetter(true);
      await wvcApiInstance.webViewPages[0].viewModel.webViewController.setOptions(options: WebViewController.to.webViewGroupOptions);
      await wvcApiInstance.webViewPages[0].viewModel.webViewController.loadUrl(
          url: MAIN_URL + MAIN_URL_LIST[1]);
      // await wvcApiInstance.mainWebViewModel.webViewController.loadUrl(url: MAIN_URL+MAIN_URL_LIST[1]);
      return;
    }

    setIndexedStack = 0;
    if (wvcApiInstance.webViewPages.length > 1) {
      wvcApiInstance.webViewPages.removeRange(1, wvcApiInstance.webViewPages.length - 1);
      wvcApiInstance.webViewPages.removeRange(1, wvcApiInstance.webViewPages.length-1);
    }
  }

  void onFileurl() {
    wvcApiInstance.removeLastWebViewPages();
    setIndexedStack=1;
  }
}

class NotificationToggleController extends GetxController{

  static NotificationToggleController get to => Get.find();

  final wvcApiInstance = WVCApi();
  bool listCheckedOut;

  onInitiate(){
    wvcApiInstance.flnApiInstance.msgSub=wvcApiInstance.flnApiInstance.msgStream.listen((event) {
      if(wvcApiInstance.flnApiInstance.notiListContainer.length>0&&event != "remove") drawerToggle=false;
      else drawerToggle=true;
    });
  }

  set drawerToggle(bool listCheckedOut){
    this.listCheckedOut=listCheckedOut;
    update();
  }

}