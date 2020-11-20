import 'package:fcm_tet_01_1008/controller/screen_holder_controller.dart';
import 'package:fcm_tet_01_1008/data/provider/wvc_api.dart';
import 'package:get/get.dart';

class SubWebViewController extends GetxController{

  static SubWebViewController get to => Get.put(SubWebViewController());

  ScreenHodlerController shController = ScreenHodlerController.to;

  final wvcApiInstance = WVCApi();

}