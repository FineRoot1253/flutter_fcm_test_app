import 'package:fcm_tet_01_1008/data/provider/http_api.dart';
import 'package:flutter/cupertino.dart';

class HttpRepository{
  final HttpApi httpApi;

  HttpRepository({@required this.httpApi}) : assert(httpApi != null);

  httpManager(String method, String url) => httpApi.httpManager(method, url);

}