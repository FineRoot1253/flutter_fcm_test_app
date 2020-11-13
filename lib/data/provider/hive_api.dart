import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveApi{
  /// singleton 시작
  static HiveApi _instance;

  HiveApi._internal(){
    _instance = this;
  }

  factory HiveApi() => _instance ?? HiveApi._internal();
  /// 끝

  final FlutterSecureStorage  secureStorage = const FlutterSecureStorage();

  init() async => await Hive.initFlutter();


  //암호화 키 생성 OR getter
  Future get encryptionKey async {

    bool containsEncryptionKey = await secureStorage.containsKey(key: "Secret_Key");

    //암호화 키 생성
    if(!containsEncryptionKey){
      print("이거 나오면 안돼");
      List<int> key = Hive.generateSecureKey();

      await secureStorage.write(key: "Secret_Key", value: base64UrlEncode(key));
    }

    return base64Url.decode(await secureStorage.read(key : "Secret_Key"));

  }

  //암호화 박스 getter
  Future get encryptedBox async {

    var encryptedBox = await Hive.openBox("LoginForm", encryptionCipher: HiveAesCipher(await this.encryptionKey));

    return encryptedBox;

  }

}