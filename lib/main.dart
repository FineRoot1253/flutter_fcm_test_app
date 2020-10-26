import 'package:fcm_tet_01_1008/bindings/webview_binding.dart';
import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class MyApp extends StatelessWidget with WidgetsBindingObserver {
  // This widget is the root of your application.



  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: WebViewBinding(),
      title:'Flutter Demo',
      home:WebViewPage(),
      getPages: routes,
    );
  }
}

void main() async {
  /// 네이티브와 플러터를 바인드를 해줄때 initial 위치가 안맞는 경우가 있음,
  /// 그럴땐 이것을 추가
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}



/// TOP_Level BackgroundMessageHandler
/// 현 상황에서 사용 불가
// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
//   print("\n\n\n\nonbackground : $message\n\n\n\n");
//   // showItemSnackBar(username: null, message: message);
//   // /// 여기에서 한번 더 flutter_local_notification인스턴스에 접근할 필요가 있어서
//   // /// flutter_local_notification을 싱글톤화 해야했다.
//
//   return Future<void>.value();
// }