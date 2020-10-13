import 'package:fcm_tet_01_1008/controller/push_item_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


//TODO: item Getobs로 연결, 연결이후 변환까지 필요
class WebViewController extends GetxController{

  static WebViewController get to => Get.find();
  Item item = Item();

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _topicController =
  TextEditingController(text: 'topic');
  bool _topicButtonsDisabled = false;

  FirebaseMessaging get fm => _firebaseMessaging;
   showDialog(Map<String, dynamic> message)  => _showItemDialog(message);
   navigateDialog(Map<String, dynamic> message) => _navigateToItemDetail(message);


  //TODO: 이동 => true 반환, 반환시 urlOverloading 시켜야함 Webview 연동 필수
  //TODO: 다이얼로그 이원화 필요, 로그인시 or 다른 업무 알람
  //TODO: 현재 다이얼로그 -> Get.dialog 필요
  // Widget _buildDialog(BuildContext context, Item item) {
  //   return AlertDialog(
  //     content: Text("${item.matchteam} with score: ${item.score}"),
  //     actions: <Widget>[
  //       FlatButton(
  //         child: const Text('닫기'),
  //         onPressed: () {
  //           Get.back(result: false);
  //           //Navigator.pop(context, false);
  //         },
  //       ),
  //       FlatButton(
  //         child: const Text('이동'),
  //         onPressed: () {
  //           Get.back(result: true);
  //           //Navigator.pop(context, true);
  //         },
  //       ),
  //     ],
  //   );
  // }

  void _showItemDialog(Map<String, dynamic> message) async {
    Item item = _itemForMessage(message);
    await Get.dialog(AlertDialog(
      content: Text("${item.matchteam} with score: ${item.score}"),
      actions: <Widget>[
        FlatButton(
          child: const Text('닫기'),
          onPressed: () {
            Get.back(result: false);
            //Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('이동'),
          onPressed: () {
            Get.back(result: true);
            //Navigator.pop(context, true);
          },
        ),
      ],
    )).then((value) {
      if(value)
        _navigateToItemDetail(message);
    });
    // showDialog<bool>(
    //   context: context,
    //   builder: (_) => _buildDialog(context, _itemForMessage(message)),
    // ).then((bool shouldNavigate) {
    //   if (shouldNavigate == true) {
    //     _navigateToItemDetail(message);
    //   }
    // });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    //TODO: url overload 추가 필요
    // Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    // if (!item.route.isCurrent) {
    //   Navigator.push(context, item.route);
    // }
  }

  //TODO: 현재 routing -> Get으로 변경 필요
  Item _itemForMessage(Map<String, dynamic> message) {
    final dynamic data = message['data'] ?? message;
    final String itemId = data['id'];
    final Item item = this.item.items.putIfAbsent(itemId, () => Item(itemId: itemId))
      ..matchteam = data['matchteam']
      ..score = data['score'];
    return item;
  }
}

