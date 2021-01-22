import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/data/provider/api.dart';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:get/get.dart';


class NotificationDrawerController extends GetxController{

  static NotificationDrawerController get to => Get.find();

  final wvcApiInstance = WVCApi();

  List<MessageModel> mainNotiList = List<MessageModel>();
  List<MessageModel> fileNotiList = List<MessageModel>();
  List<MessageModel> boardNotiList = List<MessageModel>();
  // SendPort sendPort = ;

  NotificationDrawerController(){
    onInitiate();
  }

  onInitiate(){

    wvcApiInstance.flnApiInstance.msgSub=wvcApiInstance.flnApiInstance.msgStream.listen((event) async {
      await onUpdate(event);
      update();
    });
  }

  onUpdate([String event])async{
    ///list set
    print(wvcApiInstance.flnApiInstance.notiListContainer);
    mainNotiList = wvcApiInstance.flnApiInstance.notiListContainer;
    boardNotiList = wvcApiInstance.flnApiInstance.notiListContainer.where((element) => element.msgType=="1").toList();
    fileNotiList = wvcApiInstance.flnApiInstance.notiListContainer.where((element) => element.msgType=="2").toList();
    if(event!='reset')
      await wvcApiInstance.daoIns.setList(wvcApiInstance.flnApiInstance.notiListContainer);
    // wvcApiInstance.sendToIsolate();
  }

  addList(Map<String,dynamic> message){
    wvcApiInstance.flnApiInstance.addList(message);
  }

  removeNotification(int index){
    wvcApiInstance.flnApiInstance.removeAtNotification(index);
  }

  removeLastNotification(){
    wvcApiInstance.flnApiInstance.removeLastNotification();
  }

  Future<void> clearNotificaitons() async {
    await wvcApiInstance.flnApiInstance.clearNotifications();

    return Future<void>.value();
  }

  onTileTab(MessageModel model) async {
    wvcApiInstance.receivedURL=model.url;
    wvcApiInstance.compCd=model.compCd;
    wvcApiInstance.compUserId=model.userId;

    if(ScreenHolderController.to.currentIndex==1) ScreenHolderController.to.onPressHomeBtn();
    if(wvcApiInstance.ssItem!=null&&wvcApiInstance.ssItem["procType"]!=2) {
      if(wvcApiInstance.ssItem["user"]["userId"]==wvcApiInstance.compUserId) {
        print("여기여기");
        await wvcApiInstance.webViewPages.first.viewModel.webViewController.loadUrl(url: (wvcApiInstance.receivedURL.endsWith("/smb00004")) ? FILE_STORAGE_URL : BOARD_URL);
        wvcApiInstance.receivedURL = null;
        wvcApiInstance.compCd = null;
        wvcApiInstance.compUserId = null;
      }
    }else {
      await WebViewController.to.checkAndReLoadUrl();
    }

  }

}