import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;


/// 추후 만약  HTTP REQUEST를 보내야한다면 필요한 컨트롤러
/// httpManager() -> 보낼 request 확인후 send
/// checkError() -> request이후 response에 따라 오류체크

class HttpController extends GetxController {

  static HttpController get to => Get.find();

  httpManager(String method, String url, [Map<String, dynamic> body]) async{

    var response;

    switch(method){
      case "GET":
        response = await http.get(url);
        break;
      case "DELETE":break;
      case "POST":break;
      case "PATCH":break;
      case "PUT":break;
    }

    return await checkError(response, url);
  }

  checkError(response, url) async {
    String header = response.headers['set-cookie'];
    switch (response.statusCode)  {
      case 200:
      //반환
        var responseData = jsonDecode(response.body);
        return responseData;
        break;
      case 204:
      // 정상 로그아웃
        break;
      case 401:
      // 강제 로그아웃
        break;
      case 403:
        return "Black";
      case 404:
        return "Not Found";
      case 406:
      // 블라인드 게시글
        return "blind";
        break;
      case 409:
        return "duplicate";
    // 중복 신고
      case 500:
        return "Error";
    }
  }

}