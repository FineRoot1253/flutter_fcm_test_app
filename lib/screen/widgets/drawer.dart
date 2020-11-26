import 'package:fcm_tet_01_1008/controller/notification_drawer_controller.dart';
import 'package:fcm_tet_01_1008/data/model/message_model.dart';
import 'package:fcm_tet_01_1008/screen/widgets/notification_drawer_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class NotificationDrawer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("알림보관함"),
            actions: [IconButton(icon: Icon(Icons.restore_from_trash),onPressed: (){NotificationDrawerController.to.clearNotificaitons();},)],
            leading: IconButton(icon: Icon(Icons.arrow_back_rounded),
              onPressed: (){if(!(Get.isDialogOpen&&Get.isSnackbarOpen))Get.back();}
              ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.notification_important_rounded),),
                Tab(icon: Icon(Icons.file_copy_rounded)),
                Tab(icon: Icon(Icons.dashboard_rounded))
              ],
            ),
          ),
            body: GetBuilder<NotificationDrawerController>(
              init:NotificationDrawerController(),
                initState: (_){NotificationDrawerController.to.onUpdate();},
                builder: (_) {
                  return TabBarView(
                    children: [
                      buildListView(_.mainNotiList, true),
                      buildListView(_.fileNotiList, false),
                      buildListView(_.boardNotiList, false)
                    ],
                  );
                }
            )
        ),
      ),
    );
  }

  Widget buildListView(List<MessageModel> list, bool isMain) {
    return (list.length>0) ? ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: list.length,
        itemBuilder: (context, index) =>
        NotificationDrawerListTile(msg: list[index], index: index, isMain: isMain),
    ):Center(child: Text("알람 없음"),);
  }
}


