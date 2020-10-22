import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/data/provider/http_api.dart';
import 'package:fcm_tet_01_1008/data/repository/http_repository.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class WebViewBinding implements Bindings {
  @override
  void dependencies() => Get.lazyPut<WebViewController>(() => WebViewController(
      repository: HttpRepository(httpApi: HttpApi(httpClient: http.Client()))));
}
