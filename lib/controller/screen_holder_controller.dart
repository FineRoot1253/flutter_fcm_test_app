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
  double _screenHeight;
  bool _isSignin = false;
  int _currentIndex = 0;
  AppLifecycleState _state;

  int get currentIndex => this._currentIndex;
  AppLifecycleState get state => this._state;
  bool get isSignin => this._isSignin;
  double get screenHeight => this._screenHeight;

  set toggle(bool isSigin) {
    this._isSignin = isSigin;
    update();
  }
  set setIndexedStack(int index){
    this._currentIndex=index;
    update();
  }

  set screenHeight(double screenHeight){this._screenHeight=screenHeight;}


  void changeWebViewModel(WebViewModel model){
    wvcApiInstance.addWebViewPage(WebViewPage(key: GlobalKey(), screenHeight: _screenHeight, viewModel: model));
    setIndexedStack=_currentIndex+1;
  }

  void onPressHomeBtn() async {
    if (wvcApiInstance.procType != "2") {
      await wvcApiInstance.webViewPages[0].viewModel.webViewGroupOptionSetter(true);
      await wvcApiInstance.webViewPages[0].viewModel.webViewController.setOptions(options: wvcApiInstance.webViewPages[0].viewModel.options);
      await wvcApiInstance.webViewPages[0].viewModel.webViewController.loadUrl(
          url: MAIN_URL + MAIN_URL_LIST[1]);
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