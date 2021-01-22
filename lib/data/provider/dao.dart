import 'dart:convert';

import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DAOApi{

  static DAOApi _instance;

  Box _box;

  factory DAOApi() => _instance ?? DAOApi._();

  DAOApi._(){
    _instance = this;
  }

  Future<void> init() async {
    if(!( _box !=null&&_box.isOpen)){
      String path = (await getExternalStorageDirectory()).path;
      Hive.init(path);
      _box = await Hive.openBox('messageBox');
    }

    return Future<void>.value();
  }

  Future<void> setList(List<MessageModel> list) async {
    await init();
    await _box.put("notifList", jsonEncode(list.map((e) => e.toMap()).toList()));
    List<MessageModel> list1 = await getList();
    print("저장 이후 : ${list1.length}");
    return Future<void>.value();
  }

  Future<List<MessageModel>> getList() async {
    await init();
    String str = await _box.get("notifList");
    if(str == null) return List<MessageModel>();
    List<dynamic> aRecord = jsonDecode(str).toList();
    return aRecord.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> closeBox() async {
    await _box.close();
    return Future<void>.value();
  }

}