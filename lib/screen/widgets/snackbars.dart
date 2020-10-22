import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// fc 메시지를 받아서 띄워주는 커스텀 스낵바
/// 확인 callback -> this.receivedURL = message["data"]["URL"];
///                 checkAndReLoadUrl(this.wvc).then((_) => Get.back());
/// 닫기 callback ->                 Get.back();

void showItemSnackBar(
    {@required String username,
      @required Map<String, dynamic> message}) async {

  var titleStr;
  var bodyStr;

  if (username.isNull) {
    titleStr = message["data"]["title"] ?? '알림';
    bodyStr = message["data"]["body"] ?? '';
  }

  // await
  Get.snackbar("", "",
      isDismissible: false,
      titleText: Text(
        (username.isNull) ? "$titleStr" : "어서오세요 $username님",
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.white,
      borderWidth: 10.0,
      borderColor: Colors.white,
      borderRadius: 30.0,
      duration: Duration(seconds: 5),
      messageText: Container(
        padding: const EdgeInsets.only(top: 30.0),
        margin: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (username.isNull) ? Text("$bodyStr") : Container(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (username.isNull)
                    ? FlatButton(
                    onPressed: () {
                      WebViewController.to.receivedURL = message["data"]["URL"];
                      WebViewController.to.checkAndReLoadUrl().then((_) => Get.back());
                    },
                    child: Text("확인"))
                    : Container(),
                FlatButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("닫기"))
              ],
            ),
          ],
        ),
      ));
}
