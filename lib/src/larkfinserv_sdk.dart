import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'config/constants.dart';
import 'types/sdk_types.dart';

class LarkFinServSDK {
  PartnerConfig? _config;
  final _eventController = StreamController<SDKEvent>.broadcast();
  WebViewController? _webViewController;
  String? _iframeUrl;

  Stream<SDKEvent> get events => _eventController.stream;

  Future<void> initialize(PartnerConfig config) async {
    _config = config;
    _validateConfig();
    if (_config!.environment != null) {
      SDKConstants.setEnvironment(_config!.environment!);
    }
    await _initializeSDK();
  }

  void _validateConfig() {
    if (_config == null) {
      throw SDKError(
        code: 'INVALID_CONFIG',
        message: 'Configuration is required',
      );
    }

    if (_config!.apiKey.isEmpty || _config!.apiSecret.isEmpty) {
      throw SDKError(
        code: 'INVALID_CONFIG',
        message: 'API key and secret are required',
      );
    }
  }

  Future<void> _initializeSDK() async {
    try {
      String endpoint = '${SDKConstants.sdkApiUrl}/loan-sdk/init';

      if (_config!.phoneNumber != null) {
        endpoint = '$endpoint?phone=${_config!.phoneNumber}&isVerified=true';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          ...SDKConstants.defaultHeaders,
          'X-SDK-Key': _config!.apiKey,
          'X-SDK-Secret': _config!.apiSecret,
        },
      );

      if (response.statusCode != 200) {
        throw SDKError(
          code: 'INITIALIZATION_FAILED',
          message: 'Failed to initialize SDK: ${response.body}',
        );
      }

      final data = json.decode(response.body);
      final dynamic userObject = data['user'];
      final String? extractedUserId = (userObject is Map<String, dynamic>)
          ? (userObject['id'] as String?)
          : (data['userId'] as String?);

      _config = PartnerConfig(
        partnerId: data['partnerId'],
        partnerName: data['partnerName'],
        apiKey: _config!.apiKey,
        apiSecret: _config!.apiSecret,
        sessionId: data['sessionId'],
        phoneNumber: _config!.phoneNumber,
        environment: _config!.environment,
        userId: extractedUserId,
        theme: ThemeConfig(
          primaryColor: data['themeConfig']?['primaryColor'],
          secondaryColor: data['themeConfig']?['secondaryColor'],
          fontFamily: data['themeConfig']?['fontFamily'],
          logoUrl: data['themeConfig']?['logoUrl'],
          name: data['themeConfig']?['name'],
        ),
      );

      _iframeUrl = _generateIframeUrl();
      _eventController.add(SDKEvent(type: SDKEventType.ready));
    } catch (e) {
      _eventController.add(SDKEvent(
        type: SDKEventType.error,
        data: {
          'error': SDKError(
            code: 'INITIALIZATION_ERROR',
            message: e.toString(),
          )
        },
      ));
      rethrow;
    }
  }

  String _generateIframeUrl() {
    final baseUrl = _config!.environment == 'sandbox'
        ? SDKConstants.sdkUrl
        : SDKConstants.sdkUrl;

    final params = {
      'authKey': _config!.apiKey,
      'authSecret': _config!.apiSecret,
      if (_config!.sessionId != null) 'sessionId': _config!.sessionId!,
      if (_config!.theme != null)
        'theme': json.encode(_config!.theme!.toJson()),
      if (_config!.phoneNumber != null) 'phoneNumber': _config!.phoneNumber!,
      if (_config!.userId != null) 'userId': _config!.userId!,
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Future<void> openEligibilityCheck(SDKMode mode) async {
    if (_iframeUrl == null) {
      throw SDKError(
        code: 'SDK_NOT_INITIALIZED',
        message: 'SDK must be initialized before opening eligibility check',
      );
    }

    _eventController.add(SDKEvent(type: SDKEventType.initiated));

    if (mode == SDKMode.popup) {
      final url = Uri.parse(_iframeUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw SDKError(
          code: 'URL_LAUNCH_FAILED',
          message: 'Could not launch eligibility check URL',
        );
      }
    }
  }

  WebViewController createWebViewController() {
    if (_iframeUrl == null) {
      throw SDKError(
        code: 'SDK_NOT_INITIALIZED',
        message: 'SDK must be initialized before creating WebView',
      );
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("LarkFinServBridge",
          onMessageReceived: (JavaScriptMessage message) {
        try {
          final Map<String, dynamic> payload = json.decode(message.message);
          final String? type = payload['type'] as String?;
          final dynamic data = payload['data'];
          if (type == null) return;
          switch (type) {
            case 'READY':
              _eventController.add(SDKEvent(type: SDKEventType.ready));
              break;
            case 'ELIGIBILITY_RESULT':
              _eventController.add(SDKEvent(
                type: SDKEventType.eligibilityResult,
                data: {'result': data},
              ));
              break;
            case 'ERROR':
              _eventController.add(SDKEvent(
                type: SDKEventType.error,
                data: {
                  'error': SDKError(
                    code: 'SDK_ERROR',
                    message: data?['error']?.toString() ?? 'Unknown error',
                  ),
                },
              ));
              break;
            case 'CLOSE':
              _eventController.add(SDKEvent(type: SDKEventType.close));
              break;
            case 'CLOSE_FRAME':
              _eventController.add(SDKEvent(type: SDKEventType.closeFrame));
              break;
            default:
              break;
          }
        } catch (_) {
          // ignore malformed messages
        }
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Inject a listener to forward window message events to the Flutter bridge if available
            _webViewController?.runJavaScript(
                'try {\n  if (typeof LarkFinServBridge !== \"undefined\") {\n    window.addEventListener(\"message\", function(e) {\n      try { LarkFinServBridge.postMessage(JSON.stringify(e.data)); } catch (err) {}\n    });\n  }\n} catch (err) {}');
            _eventController.add(SDKEvent(type: SDKEventType.ready));
          },
          onWebResourceError: (WebResourceError error) {
            _eventController.add(SDKEvent(
              type: SDKEventType.error,
              data: {
                'error': SDKError(
                  code: 'WEBVIEW_ERROR',
                  message: error.description,
                )
              },
            ));
          },
        ),
      )
      ..loadRequest(Uri.parse(_iframeUrl!));

    return _webViewController!;
  }

  Future<void> sendData(Map<String, dynamic> data) async {
    if (_webViewController == null) {
      throw SDKError(
        code: 'SDK_NOT_INITIALIZED',
        message: 'WebView not created. Call createWebViewController() first.',
      );
    }
    final Map<String, dynamic> payload = {
      'type': 'USER_DATA_UPDATE',
      'data': data,
      'metadata': {
        'partnerId': _config?.partnerId,
      },
    };
    final String js = 'window.postMessage(${jsonEncode(payload)}, "*")';
    await _webViewController!.runJavaScript(js);
  }

  void dispose() {
    _eventController.close();
    _webViewController = null;
  }
}
