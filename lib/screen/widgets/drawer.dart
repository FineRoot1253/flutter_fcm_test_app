import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/screen/widgets/notification_drawer_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';

class NotificationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        length: 3,
        child: GetBuilder<NotificationDrawerController>(
            init: NotificationDrawerController(),
            initState: (_) {
              NotificationDrawerController.to.onUpdate();
            },
            builder: (_) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text("알림보관함"),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.restore_from_trash),
                        onPressed: () async {
                          _.clearNotificaitons();
                          await _.wvcApiInstance.flnApiInstance.flnPlugin.cancelAll();
                          // FlutterAppBadger.removeBadge();
                        },
                      )
                    ],
                    leading: IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          if (!(Get.isDialogOpen && Get.isSnackbarOpen))
                            Get.back();
                        }),
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          icon: buildTabIcon(Icons.notification_important_rounded,_.mainNotiList.length),
                        ),
                        Tab(icon: buildTabIcon(Icons.file_copy_rounded,_.fileNotiList.length)),
                        Tab(icon: buildTabIcon(Icons.dashboard_rounded,_.boardNotiList.length))
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      buildListView(_.mainNotiList, true),
                      buildListView(_.fileNotiList, false),
                      buildListView(_.boardNotiList, false)
                    ],
                  ));
            }),
      ),
    );
  }

  Widget buildTabIcon(IconData iconData,int length) {
    return SizedBox(
      width: Get.width*0.085,
      child: Stack(children: [
        Icon(iconData),
        Positioned(
            right: -3.5,
            child: Container(
              alignment: Alignment.center,
              width: Get.width*0.05,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                margin: EdgeInsets.all(2.0),
                child: Text(
                  "$length",
                  style: TextStyle(fontSize: 8, color: Colors.blue),
                ),
              ),
            ))
      ]),
    );
  }

  Widget buildListView(List<MessageModel> list, bool isMain) {
    return (list.length > 0)
        ? ListView.separated(
            separatorBuilder: (context, index) => Divider(height: 0.1,),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: list.length,
            itemBuilder: (context, index) => NotificationDrawerListTile(
                msg: list[index], index: index, isMain: isMain),
          )
        : Center(
            child: Text("알람 없음"),
          );
  }
}
