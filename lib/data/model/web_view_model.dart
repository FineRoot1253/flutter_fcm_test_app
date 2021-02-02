import 'dart:collection';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewModel {
  /// Object Elements
  double _progress;
  String _url;

  int windowId;
  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options;
  LinkedHashMap<String, dynamic> ssItem;

  /// constructor
  WebViewModel({
    progress = 0.0,
    url,
    this.windowId,
    this.webViewController,
    this.options
  }){
    _progress = _progress ?? 0.0;
    _url = url;
    options = options ?? InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true
        ),
        crossPlatform: InAppWebViewOptions(
          horizontalScrollBarEnabled: false,
          verticalScrollBarEnabled: false,
          javaScriptEnabled: true,
          javaScriptCanOpenWindowsAutomatically: true,
          clearCache: true,
          debuggingEnabled: true,
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: true,
          useOnLoadResource: true,
        )
    );
  }

  /// getters
  double get progress => _progress;
  String get url => _url;

  webViewGroupOptionSetter(bool isSignin){
    this.options = InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
            supportMultipleWindows: true
        ),
        crossPlatform: InAppWebViewOptions(
          horizontalScrollBarEnabled: false,
          verticalScrollBarEnabled: false,
          javaScriptCanOpenWindowsAutomatically: true,
          clearCache: true,
          debuggingEnabled: true,
          useShouldOverrideUrlLoading: true,
          useShouldInterceptAjaxRequest: isSignin,
          useOnLoadResource: true,
        )
    );
  }
}
