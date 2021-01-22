import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


/// 여기에 전역으로 사용할 필요한 스낵바들을 정의

/// fc 메시지를 받아서 띄워주는 커스텀 스낵바
/// 확인 callback -> this.receivedURL = message["data"]["URL"];
///                 checkAndReLoadUrl(this.wvc).then((_) => Get.back());
/// 닫기 callback ->                 Get.back();

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