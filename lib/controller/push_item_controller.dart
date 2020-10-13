import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Item{
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;
  String _matchteam;
  String get matchteam => _matchteam;
  set matchteam(String value) {
    _matchteam = value;
    _controller.add(this);
  }

  String _score;
  String get score => _score;
  set score(String value) {
    _score = value;
    _controller.add(this);
  }

  //TODO: item에 따라 URL overload function 필요
  // static final Map<String, Route<void>> routes = <String, Route<void>>{};
  // Route<void> get route {
  //   final String routeName = '/detail/$itemId';
  //   return routes.putIfAbsent(
  //     routeName,
  //         () => MaterialPageRoute<void>(
  //       settings: RouteSettings(name: routeName),
  //       builder: (BuildContext context) => DetailPage(itemId),
  //     ),
  //   );
  // }

  final Map<String, Item> _items = <String, Item>{};
  Map<String, Item> get items => _items;


}