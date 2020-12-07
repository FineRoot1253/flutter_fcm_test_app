import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDrawerListTile extends StatelessWidget {
  final MessageModel msg;
  final bool isMain;
  final int index;
  final NotificationDrawerController _controller =
      NotificationDrawerController.to;

  NotificationDrawerListTile({this.msg, this.index, this.isMain});

  @override
  Widget build(BuildContext context) {
    return isMain ? buildCustomListTile() : buildSubListTile();
  }

  Widget buildSubListTile() {
    return ListTile(
      dense: true,
      title: Text(subStringStr(msg.compNm)),
      subtitle: Text(subStringStr(msg.body)),
      trailing: Text(splitDateString(), style: TextStyle(fontSize: 10),),
      onTap: () async {
        _controller.removeNotification(index);
        await _controller.onTileTab(msg);
        Get.back();
      },
    );
  }

  Widget buildMainListTile() {
    // TODO : msgType에 따라 사진 다르게 붙이기
    return ListTile(
      dense: true,
      leading: SizedBox(
          height: Get.width * 0.09,
          width: Get.width * 0.09,
          child: msg.msgType == "1"
              ? Image.asset("assets/images/board.png",
                  fit: BoxFit.fill, isAntiAlias: true)
              : Image.asset("assets/images/file.png",
                  fit: BoxFit.fill, isAntiAlias: true)),
      title: Text(msg.compNm, style: TextStyle(fontSize: 10)),
      subtitle: Text(msg.body, style: TextStyle(fontSize: 10)),
      trailing:
          Text(splitDateString(), style: TextStyle(fontSize: 10),),
      onTap: () async {
        _controller.removeNotification(this.index);
        await _controller.onTileTab(msg);
        Get.back();
      },
    );
  }
  Widget buildCustomListTile(){
    return InkWell(
      onTap: () async {
        _controller.removeNotification(this.index);
        await _controller.onTileTab(msg);
        Get.back();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
                height: Get.width * 0.09,
                width: Get.width * 0.09,
                child: msg.msgType == "1"
                    ? Image.asset("assets/images/board.png",
                    fit: BoxFit.fill, isAntiAlias: true)
                    : Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: Image.asset("assets/images/file.png",
                      fit: BoxFit.fill, isAntiAlias: true),
                    )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(subStringStr(msg.compNm), style: TextStyle(fontSize: 10)),
                  Text(subStringStr(msg.body), style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
            Text(splitDateString(), style: TextStyle(fontSize: 10))
          ],
        ),
      ),
    );
  }
  splitDateString(){
    var result = msg.receivedDate.toString().split(" ");
    return result[0]+"\n"+result[1];
  }
  subStringStr(String str){
    return str.length>18 ? str.substring(0,18)+"..." : str;
  }
}
