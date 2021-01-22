import 'package:firebase_messaging/firebase_messaging.dart';

class FCMApi{

  final FirebaseMessaging _fm = FirebaseMessaging();

  /// fcm에 접근시키기위한 변수

  FirebaseMessaging get fcmPlugin => _fm;

  void fcmInitialize(){

    //TODO: IOS를 위한 퍼미션, 현재 테스트 불가능 -> 맥OS 필요
    _fm.requestNotificationPermissions(const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: true));

    _fm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    /// fm.subscribeToTopic()으로 미리 토픽을 fc쪽에 구독(등록)한다.
    _fm.subscribeToTopic("ALL");
  }

}