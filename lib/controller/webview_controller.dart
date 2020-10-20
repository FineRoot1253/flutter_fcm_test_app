import 'dart:collection';
import 'package:fcm_tet_01_1008/keyword/url.dart';
import 'package:fcm_tet_01_1008/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class WebViewController extends GetxController {
  /// CV의 편한 연결을 위해 추가
  static WebViewController get to => Get.find();

  /// FCM 연결용
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  /// notification의 확장성을 위해 추가한 플러그인, FCM과 연동
  final plugin = FlutterLocalNotificationsPlugin();

  /// 안드로이드용 체널 구성
  /// fullScreenIntent -> notificaiton 호출시 화면에 크게 띄움
  /// color -> 색조정
  /// importance -> notification 중요도
  /// priority -> notification 우선도, 우선도에 따라 백그라운드 작동이 달라짐 유의할 것
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'fcm_default_channel', 'your channel name', 'your channel description',
      fullScreenIntent: true,
      color: Colors.blue.shade800,
      ongoing: true,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("app_icon"),
      priority: Priority.high);

  /// 추후 IOS 테스트시 여기에도 추가를 해주어야 함, 현재는 default
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics;

  /// FCM에서 받은 URL 변수, 체크 및 리로드용
  String receivedURL;

  ///로그인 체크 변수, 로그인 환영 메시지 호출 여부
  bool isSignin = false;

  ///onProgressChange가 2번 호출되는 문제로 중복 back 방지용
  bool isLoadDone = false;

  /// 웹뷰의 웹뷰 컨트롤러, 쉬운 접근을 위해 여기에 선언
  InAppWebViewController wvc;

  /// 세션 스토리지의 내용이 들어가는 링크드해쉬맵, 쉬운 접근을 위해 여기에 선언
  LinkedHashMap<String, dynamic> ssItem;

  /// V -> C FM 접근용
  FirebaseMessaging get fm => _firebaseMessaging;

  ///progress indicator용 변수
  double progress = 0;

  /// view에서 로그인, 로그아웃 체크용도
  checkSignin(String currentURL) => _checkSignin(currentURL);

  ///progress 변경시 호출
  progressChanged(double progress) => _progressChanged(progress);

  ///로드 시작시 호출
  Future progressDialog() => _progressDialog();

  /// view initstate에서 호출용
  initNotifications() async {
    /// 아이콘은 미리 등록을 해두는 것이 좋음
    /// 현재 미리 등록 되어있는 디폴트 아이콘 사용
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/noti_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await plugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    /// message = fixMessageTitleAndBody(message); 1)
    /// fcm자체 버그로 인해 notification 속성이 비워져서 날라오기 때문에 필수
    /// 이를 위해 필요한 정보는 모두 백에서 보낼때 data에 넣음
    /// 따라서 data속성에 필요한 정보를 강제로 꺼내서 notification value에 넣어줘야함

    fm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        message = fixMessageTitleAndBody(message); //1)
        print("onLaunch: $message");
        _showItemSnackBar(username: null, message: message);
        //webViewController.navigateDialog(message);
        await checkAndReLoadUrl();
      },
      onResume: (Map<String, dynamic> message) async {
        message = fixMessageTitleAndBody(message); //1)
        print("ㅁㄴㅇㄻㄴㅇㄻㄴㄻㄴㅇㄻㄴㄹ : onResume: $message");
        await checkAndReLoadUrl();
      },
      onMessage: (Map<String, dynamic> message) async {
        message = fixMessageTitleAndBody(message); //1)
        print("onMessage: $message");
        _showItemSnackBar(username: null, message: message);
        await checkAndReLoadUrl();
      },

      /// main에 미리 선언 해둔 콜백 func
      /// background에서 접근 권한이 없음
      /// 빌드시 미리 이 핸들러를 TOP_LEVEL에 선언 OR static화 해두어야 isolate된 BackGround에서 접근 가능
      onBackgroundMessage: myBackgroundMessageHandler,
    );

    //TODO: IOS를 위한 퍼미션, 현재 테스트 불가능 -> 맥OS 필요
    fm.requestNotificationPermissions(const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: true));

    fm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    ///  로그인시 토큰 체크용, TODO: 추후 DB에 저장 필요
    fm.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });

    /// fm.subscribeToTopic()으로 미리 토픽을 fc쪽에 구독(등록)한다.
    fm.subscribeToTopic("ALL");
  }

  ///progress 변경시 콜백
  _progressChanged(double progress) {
    this.progress = progress;
    print("변경완료 : ${this.progress}");

    update();

    if(progress==1.0&&!this.isLoadDone){
      print("뒤로 가시오");
      this.isLoadDone=true;
      this.progress=0;
      Get.back();
    }
  }

   _progressDialog() {
    print(this.progress);
    return Get.defaultDialog(
      barrierDismissible: false,
        title: 'Loading...',
        content: GetBuilder<WebViewController>(builder: (_) {
         return (this.progress<1.0)? Center(
            child: CircularProgressIndicator(
              value: this.progress,
            ),
          ) : Center(
            child: Text("완료"),
          );
        }));
  }

  /// goto line 57
  Map<String, dynamic> fixMessageTitleAndBody(Map<String, dynamic> message) {
    if (!message.containsKey("notification")) {
      message["notification"] = {};
    }
    if (!message["notification"].containsKey("title") &&
        message["data"].containsKey("title")) {
      message["notification"]["title"] = message["data"]["title"];
    }
    if (!message["notification"].containsKey("body") &&
        message["data"].containsKey("body")) {
      message["notification"]["body"] = message["data"]["body"];
    }
    return message;
  }

  /// display a dialog with the notification details, tap ok to go to another page
  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  /// payload 체크용
  Future onSelectNotification(String payload) async {
    print("페이로드 : $payload");

    /// 받은 URL 업데이트
    String res = payload ?? null;
    if (!(res == null)) {
      receivedURL = payload;
      print("receivedURL 업로드");
    }

    /// 리로드 체크
    await checkAndReLoadUrl();
  }

  /// fc 메시지를 받아서 띄워주는 커스텀 스낵바
  /// 확인 callback -> this.receivedURL = message["data"]["URL"];
  ///                 checkAndReLoadUrl(this.wvc).then((_) => Get.back());
  /// 닫기 callback ->                 Get.back();
  ///TODO 추후 확장성을 위해 class화 필요
  void _showItemSnackBar(
      {@required String username,
      @required Map<String, dynamic> message}) async {
    var titleStr;
    var bodyStr;

    if (username.isNull) {
      titleStr = message["data"]["title"] ?? '알림';
      bodyStr = message["data"]["body"] ?? '';
    }

    // await
    Get.snackbar("", "",
        isDismissible: false,
        titleText: Text(
          (username.isNull) ? "$titleStr" : "어서오세요 $username님",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        borderWidth: 10.0,
        borderColor: Colors.white,
        borderRadius: 30.0,
        duration: Duration(seconds: 5),
        messageText: Container(
          padding: const EdgeInsets.only(top: 30.0),
          margin: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (username.isNull) ? Text("$bodyStr") : Container(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (username.isNull)
                      ? FlatButton(
                          onPressed: () {
                            this.receivedURL = message["data"]["URL"];
                            checkAndReLoadUrl().then((_) => Get.back());
                          },
                          child: Text("확인"))
                      : Container(),
                  FlatButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text("닫기"))
                ],
              ),
            ],
          ),
        ));
  }

  _checkSignin(String currentURL) {
    ///로그인이후 결과인지 체크, 맞으면 로그인환영 스낵바 호출
    print("검사 가능 확인 : ${this.progress==0}");
    if (!ssItem.isNull && !isSignin&&this.progress==0) {
      print("환영메시지 호출");
      var username = ssItem["user"]["userNm"];
      _showItemSnackBar(message: null, username: username);
      isSignin = true;
    }

    ///로그아웃하는 중인지 체크, 로그아웃하는 url이면 로그아웃절차 시작
    ///!ssItem.isNull, 로그인상태 여부 체크
    if (currentURL.endsWith("/m/") && !ssItem.isNull) {
      ssItem = null;
      print("로그아웃 완료 : ${ssItem.isNull}");
      isSignin = false;
    }
  }

  /// checkAndReLoadUrl(), fcm에서 링크가 보내지면 리로드 동작, 평소에는 URL변수가 null -> 체크후 return;
  /// fcm의 의해 새로운 링크가 추가되었는지 체크 -> 웹뷰 리로드 -> URL변수 null 초기화
  Future<void> checkAndReLoadUrl() async {
    ///FCM onResume callback & InAppWebView onLoadStart
    ///this.wvc=controller; -> 넣는 위치에 따라 필요여부 있음
    ///push notification or snackBar 에 의해 한번 거치게되면 receivedURL=null,
    ///세션스토리지 Null 유무로 로그인체크
    ///-> 재호출시 리로드가 되지 않아야 함
    ///receivedURL.isNull -> notification을 타고 왔는지 구분 가능
    print("세션 스토리지 : $ssItem\n받은 URL : $receivedURL");
    print("리로드 사용 여부 체크 : ${!ssItem.isNull} : ${!receivedURL.isNull}");
    if (!ssItem.isNull && !receivedURL.isNull && receivedURL != "/") {
      await wvc.loadUrl(url: MAIN_URL + receivedURL);
      receivedURL = null;
      print("receivedURL null 초기화");
    }
  }
}
