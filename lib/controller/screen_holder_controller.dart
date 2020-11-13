import 'package:get/get.dart';

class ScreenHodlerController extends GetxController {

  static ScreenHodlerController get to => Get.put(ScreenHodlerController());

  bool isSignin = false;

  set toggle(bool isSigin) {
    this.isSignin = isSigin;
    update();
  }

}