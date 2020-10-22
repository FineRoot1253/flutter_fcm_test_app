

import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///여기에 전역으로 사용할 다이얼로그들을 정의

progressDialog() {
  return Get.defaultDialog(
      barrierDismissible: false,
      title: 'Loading...',
      content: GetBuilder<WebViewController>(builder: (_) {
        return (_.progress<1.0)? Center(
          child: CircularProgressIndicator(
            value: _.progress,
          ),
        ) : Center(
          child: Text("완료"),
        );
      }));
}

