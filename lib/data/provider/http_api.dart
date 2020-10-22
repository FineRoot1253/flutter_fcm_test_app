import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HttpApi{

  final http.Client httpClient;
  HttpApi({@required this.httpClient});

  httpManager(String method, String url, [Map<String, dynamic> body]) async{

    var response;

    switch(method){
      case "GET":
        response = await http.get(url);
        break;
      case "DELETE":
        response =
        await http.delete(url);
        break;
      case "POST":
        if (url.endsWith("login") || url.endsWith("register"))
          response = await http.post(url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(body),
              encoding: Encoding.getByName("utf-8"));
        else
          response = await http.post(url, body: body);
        break;
      case "PATCH":
        response = await http.patch(url, body: body);
        break;
      case "PUT":
        response = await http.put(url, body: body);
        break;
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
/// 추후에 쿠키를 저장하거나 하는 일이 존재한다면
/// hive같은 자체 DB에 저장을 시켜야 함
/// 그런 메서드를 를 추후에 이곳에 위치 시킬것
}