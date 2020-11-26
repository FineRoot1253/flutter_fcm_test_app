import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDrawerListTile extends StatelessWidget {

  final MessageModel msg;
  final bool isMain;
  final int index;
  final NotificationDrawerController _controller = NotificationDrawerController.to;

  NotificationDrawerListTile({this.msg, this.index, this.isMain});

  @override
  Widget build(BuildContext context) {
    return isMain ? buildMainListTile() : buildSubListTile();
  }

  Widget buildSubListTile(){
    return ListTile(
      dense:true,
      title:Text(msg.compNm),
      subtitle: Text(msg.body),
      trailing: Text(msg.receivedDate),
      onTap: () async {
        _controller.removeNotification(index);
        await _controller.onTileTab(msg);
        Get.back();
      },
    );
  }
  Widget buildMainListTile(){
    // TODO : msgType에 따라 사진 다르게 붙이기
    return ListTile(
      dense:true,
      leading: SizedBox(
        height: Get.width*0.09,
        width: Get.width*0.09,
        child: msg.msgType=="1"?Image.asset("assets/images/board.png",fit: BoxFit.fill,isAntiAlias: true):Image.asset("assets/images/file.png",fit: BoxFit.fill,isAntiAlias: true)
      ),
      title:Text(msg.compNm),
      subtitle: Text(msg.body),
      trailing: Text(msg.receivedDate ),
      onTap: () async {
        _controller.removeNotification(this.index);
        await _controller.onTileTab(msg);
        Get.back();
      },
    );
  }

}
