import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


/// 여기에 전역으로 사용할 필요한 스낵바들을 정의

/// fc 메시지를 받아서 띄워주는 커스텀 스낵바
/// 확인 callback -> this.receivedURL = message["data"]["URL"];
///                 checkAndReLoadUrl(this.wvc).then((_) => Get.back());
/// 닫기 callback ->                 Get.back();


void showItemSnackBar(
    {@required String username,
      @required Map<String, dynamic> message,
      @required WebViewController controller
    }) async {

  var titleStr;
  var bodyStr;

  if (username.isNull) {
    titleStr = message["data"]["title"] ?? '알림';
    bodyStr = message["data"]["body"] ?? '';
  }

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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (username.isNull) ? Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text("$bodyStr"),
                ) : Container(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (username.isNull)
                        ? Container(
                      margin: const EdgeInsets.all(10.0),
                      child: OutlineButton(
                          color: Colors.blue,
                          shape: StadiumBorder(),
                          borderSide: BorderSide(color: Colors.blue,
                              style: BorderStyle.solid,
                              width: 1),
                          onPressed: () {
                            WebViewController.to.receivedURL =
                            message["data"]["URL"];
                            WebViewController.to.compCd = message["data"]["compCd"];
                            WebViewController.to.checkAndReLoadUrl().then((_) =>
                                Get.back());
                          },
                          child: Text(
                              "확인", style: TextStyle(color: Colors.blue))),
                    )
                        : Container(),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: OutlineButton(
                          color: Colors.blue,
                          shape: StadiumBorder(),
                          borderSide: BorderSide(color: Colors.blue,
                              style: BorderStyle.solid,
                              width: 1),
                          onPressed: ()=>Get.back(),
                          child: Text(
                            "닫기", style: TextStyle(color: Colors.blue),)),
                    )
                  ],
                ),
              ],
            ),
          ));
}

showToast(context){
  try{
  Fluttertoast.showToast(
    msg: "\'뒤로\'버튼을 한번 더 터치하면 앱이 종료됩니다.",
    toastLength: Toast.LENGTH_SHORT
  );}catch(e){
    print("오류 발생 : $e");
  }
}

autoLoginDialog(){
  return Get.defaultDialog(
    barrierDismissible: false,
    title: "로그인 체크...",
    content :
      CircularProgressIndicator()
  );
}