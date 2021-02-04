import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AJAXApi {

  /// singleton logic START
  static AJAXApi _instance;

  AJAXApi._internal(){
    _instance=this;
  }

  factory AJAXApi() => _instance ?? AJAXApi._internal();
  /// singleton logic END

  /// ajaxRequest 스트림 컨트롤 변수
  StreamController<AjaxRequest> streamController = StreamController<AjaxRequest>.broadcast();

  /// ajaxRequest 스트림 subscription
  StreamSubscription<AjaxRequest> ajaxStreamSubScription;

  /// ajaxRequest 동기처리용 변수
  /// 이것을 await, done이 되면 complete
  Completer ajaxCompleter;

  /// ajaxRequest 스트림 변수
  /// 이 스트림을 init에서 listen
  /// 이벤트 발생시 completer를 complete
  Stream<AjaxRequest> get ajaxStream => streamController.stream;

  /// 스트림 발생용 setter
  set ajaxLoadDone(AjaxRequest val){
    print("AJAX 끝내기!!!!");
    streamController.add(val);
  }

}