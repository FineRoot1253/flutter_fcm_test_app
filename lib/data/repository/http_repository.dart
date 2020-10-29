import 'package:fcm_tet_01_1008/data/provider/http_api.dart';
import 'package:flutter/cupertino.dart';


/// 본래 바인딩용 repo로는 메소드가 전무함
/// 나중에 용도에 맞게 변형 필요

class HttpRepository{
  final HttpApi httpApi;

  HttpRepository({@required this.httpApi}) : assert(httpApi != null);

  httpManager(String method, String url) => httpApi.httpManager(method, url);

}