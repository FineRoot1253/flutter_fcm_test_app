import 'dart:async';

import 'package:fcm_tet_01_1008/routes/routes.dart';
import 'package:fcm_tet_01_1008/screen/web_view_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//backgroundMessageHandler로 미리 static or 최상위에 선언 필수
//백그라운드 플러그인을 백그라운드(네이티브 단)에서 빌드 할때 콜백함수가 반드시 필요하기 때문



// final Map<String, Item> _items = <String, Item>{};
//
//
// Item _itemForMessage(Map<String, dynamic> message) {
//   final dynamic data = message['data'] ?? message;
//   final String itemId = data['id'];
//   final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
//     .._matchteam = data['matchteam']
//     .._score = data['score'];
//   return item;
// }
// Item은 push notification을 받는 클래스이며
// 해당 클래스변수는 Stream이기 때문에 사용 위치에서 구독 필요
// Reactive한 구조를 위해 선택


// class DetailPage extends StatefulWidget {
//   DetailPage(this.itemId);
//   final String itemId;
//   @override
//   _DetailPageState createState() => _DetailPageState();
// }
//
// class _DetailPageState extends State<DetailPage> {
//   Item _item;
//   StreamSubscription<Item> _subscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _item = _items[widget.itemId];
//     //이 부분만 따로 뜯어내서 bloc으로 만드는것이 좋아 보임
//     _subscription = _item.onChanged.listen((Item item) {
//       if (!mounted) {
//         _subscription.cancel();
//       } else {
//         setState(() {
//           _item = item;
//         });
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text("Match ID ${_item.itemId}"),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(20.0),
//           child: Card(
//             child: Container(
//                 padding: EdgeInsets.all(10.0),
//                 child: Column(
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                       child: Column(
//                         children: <Widget>[
//                           Text('Today match:', style: TextStyle(color: Colors.black.withOpacity(0.8))),
//                           Text( _item.matchteam, style: Theme.of(context).textTheme.title)
//                         ],
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
//                       child: Column(
//                         children: <Widget>[
//                           Text('Score:', style: TextStyle(color: Colors.black.withOpacity(0.8))),
//                           Text( _item.score, style: Theme.of(context).textTheme.title)
//                         ],
//                       ),
//                     ),
//                   ],
//                 )
//             ),
//           ),
//         ),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title:'Flutter Demo',
      home:WebViewPage(),
      getPages: routes,
    );
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: MyHomePage(title: 'Flutter Demo Home Page'),
    // );
  }
}

void main() {
  runApp(MyApp());
}