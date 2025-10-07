import 'package:larkfinserv_flutter/larkfinserv_flutter.dart';

class LarkSdkNavigator {
  static GlobalKey<NavigatorState>? _navigatorKey;

  /// Host app can set this key
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Open the Eligibility Check WebView
  static void openEligibilityWebView({required String url, String title = "Eligibility Check"}) {
    if (_navigatorKey == null) {
      throw Exception("Navigator key is not set. Please call LarkSdkNavigator.setNavigatorKey() first.");
    }

    _navigatorKey!.currentState?.push(
      MaterialPageRoute(
        builder: (context) => EligibilityCheckWebView(url: url, title: title),
      ),
    );
  }
}
