import 'package:fcm_tet_01_1008/controller/main_webview_controller.dart';
import 'package:fcm_tet_01_1008/data/provider/http_api.dart';
import 'package:fcm_tet_01_1008/data/repository/http_repository.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

/// 미리 사용할 UI위젯에 바인딩을 해주는 용도

class WebViewBinding implements Bindings {
  @override
  void dependencies() => Get.lazyPut<MainWebViewController>(() => MainWebViewController(
      repository: HttpRepository(httpApi: HttpApi(httpClient: http.Client()))));
}
