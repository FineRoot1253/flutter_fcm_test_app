import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveApi{
  /// singleton 시작
  static HiveApi _instance;

  bool isInited = false;
  HiveApi._internal(){
    _instance = this;
  }

  factory HiveApi() => _instance ?? HiveApi._internal();
  /// 끝

  init() async => await Hive.initFlutter();


  //암호화 박스 getter
  Future get getBox async {
    print("하이브 : $isInited");
    if(!isInited) {
      Hive.registerAdapter(MessageModelListAdapter());
      this.isInited=true;
      print("하이브 돌아요");
    }
      return await Hive.openBox("Notifications");
  }

}

