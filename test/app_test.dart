// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:fcm_tet_01_1008/controller/webview_controller.dart';
import 'package:fcm_tet_01_1008/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';

void main() async {
  WebViewController controller;
  MockMethodChannel methodChannel;
  controller = Get.put<WebViewController>(WebViewController());
  methodChannel = MockMethodChannel();

  // final Map<String, String> envVars = Platform.environment;
  // final String adbPath = envVars['ANDROID_SDK_ROOT'].toString() + '/platform-tools/adb.exe';
  // await Process.run(adbPath, [
  //   'shell',
  //   'pm',
  //   'grant',
  //   'com.example.fcm_tet_01_1008',
  //   'android.permission.READ_EXTERNAL_STORAGE'
  // ]);
  // await Process.run(adbPath, [
  //   'shell',
  //   'pm',
  //   'grant',
  //   'com.example.fcm_tet_01_1008',
  //   'android.permission.READ_PHONE_STATE'
  // ]);

  String id = 'bizbooks2';
  String pw = '1';

  testWidgets('Test 1) init login test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await Future.delayed(Duration(seconds: 5));
    await controller.wvcApiInstance.webViewPages.first.viewModel.webViewController
        .evaluateJavascript(
      source: """
       document.getElementById("userId").value="$id";
       document.getElementById("password").value="$pw";
       document.getElementById("m_btnLogin").click();
      """,
    );
    await controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
    String url = await controller
        .wvcApiInstance.webViewPages.first.viewModel.webViewController
        .getUrl();
    expect(url,
        'https://bizbooks.newzensolution.co.kr/bizbooks_test/m/taxagent/custlist');

    // Phoenix.rebirth(context); // 문제!
    // await controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
    //
    // String url1 = await controller.wvcApiInstance.mainWebViewModel.webViewController.getUrl();
    // expect(url1,
    //     'https://bizbooks.newzensolution.co.kr/bizbooks_test/m/taxagent/custlist');
    //
    // await controller.wvcApiInstance.mainWebViewModel.webViewController.evaluateJavascript(source: """document.getElementById("m_taxagent_header_btnLogout").click();""",);
    // await controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
    //
    // String url2 = await controller.wvcApiInstance.mainWebViewModel.webViewController.getUrl();
    // expect(url2, 'https://bizbooks.newzensolution.co.kr/bizbooks_test/m/login');

  });

  // testWidgets('Test 2) file URL open test', (WidgetTester tester) async {
  //   String url = await controller
  //       .wvcApiInstance.mainWebViewModel.webViewController
  //       .getUrl();
  //
  //   final viewBtn = find.byKey(Key('보기'));
  //   await tester.tap(viewBtn);
  //   //await tester.pump();
  //
  //   verify(methodChannel.invokeMethod<bool>('launch', <String, Object>{
  //     'url': url,
  //     'useSafariVC': true,
  //     'useWebView': false,
  //     'enableJavaScript': false,
  //     'enableDomStorage': false,
  //     'universalLinksOnly': false,
  //     'headers': <String, String>{},
  //   }));
  // });
  //
  // testWidgets('Test 3) file storing test', (WidgetTester tester) async {
  //   String url = await controller
  //       .wvcApiInstance.mainWebViewModel.webViewController
  //       .getUrl();
  //
  //   var uri = Uri.parse(url);
  //   String path = uri.path;
  //   String fileName = path.substring(path.lastIndexOf("/") + 1);
  //   final storeBtn = find.byKey(Key('저장'));
  //   await tester.tap(storeBtn);
  //   //await tester.pump();
  //
  //   verify(methodChannel.invokeMethod<bool>('enqueue', <String, dynamic>{
  //     'url': url,
  //     'fileName': fileName,
  //     'savedDir': (await getExternalStorageDirectory()).path,
  //     'showNotification': true,
  //     'openFileFromNotification': true
  //   }));
  // });

  // testWidgets('Test 4) auto login test', (WidgetTester tester) async {
  //   await controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
  //
  //   String url = await controller.wvcApiInstance.mainWebViewModel.webViewController.getUrl();
  //   expect(url,
  //       'https://bizbooks.newzensolution.co.kr/bizbooks_test/m/taxagent/custlist');
  // });
  //
  // testWidgets('Test 5) logout test', (WidgetTester tester) async {
  //   controller.wvcApiInstance.mainWebViewModel.webViewController.evaluateJavascript(source: """document.getElementById("m_taxagent_header_btnLogout").click();""",);
  //   await controller.wvcApiInstance.ajaxApiInstance.ajaxCompleter.future;
  //
  //   String url = await controller.wvcApiInstance.mainWebViewModel.webViewController.getUrl();
  //   expect(url, 'https://bizbooks.newzensolution.co.kr/bizbooks_test/m/login');
  // });

// testWidgets('1) fcm init test', (WidgetTester tester) async {
// });
}

class MockMethodChannel extends Mock implements MethodChannel {}
