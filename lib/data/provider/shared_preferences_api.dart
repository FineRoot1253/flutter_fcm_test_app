import 'dart:convert';

import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPApi{
  /// singleton 시작
  static SPApi _instance;

  bool isInited = false;
  SPApi._internal(){
    _instance = this;
  }

  factory SPApi() => _instance ?? SPApi._internal();
  /// 끝

  SharedPreferences _prefs;

  init() async {
    if(!isInited) {
      _prefs = await SharedPreferences.getInstance();
      isInited = true;
    }
  }

  Future setList(List<MessageModel> list) async {
    print("리스트 저장 : ${list.length}");
    await _prefs.setString("notiList", jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  List<MessageModel> get getList {
    var strList = _prefs.getString("notiList");
    if(strList==null) return null;
    List<dynamic> list =  jsonDecode(strList).toList();
    return list.map((e) => MessageModel.fromJson(e)).toList();
  }


}

