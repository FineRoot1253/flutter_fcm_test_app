import 'package:fcm_tet_01_1008/screen/sub_web_view_page.dart';
import 'package:fcm_tet_01_1008/screen/main_web_view_page.dart';
import 'package:get/get.dart';

/// 추후에 추가될 라우트는 여기에 선언

final routes = [GetPage(name: '/mainwv',page: ()=>MainWebViewPage()),
                GetPage(name: '/dbwv', page: () =>SubWebViewPage())];