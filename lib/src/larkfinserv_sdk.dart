import 'package:larkfinserv_flutter/larkfinserv_flutter.dart';
import 'package:http/http.dart' as http;

class LarkFinServSDK {
  PartnerConfig? _config;
  final _eventController = StreamController<SDKEvent>.broadcast();
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
      late final http.Response response;
      try {
        response = await http.get(Uri.parse(endpoint), headers: {
          ...SDKConstants.defaultHeaders,
          'X-SDK-Key': _config!.apiKey,
          'X-SDK-Secret': _config!.apiSecret,
        });
      } catch (e, stack) {
        log("HTTP Error: $e");
        log("Stacktrace: $stack");
      }

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

  Future<void> openEligibilityCheck(BuildContext context) async {
    if (_iframeUrl == null) {
      throw SDKError(
        code: 'SDK_NOT_INITIALIZED',
        message: 'SDK must be initialized before opening eligibility check',
      );
    }
    _eventController.add(SDKEvent(type: SDKEventType.initiated));
    final url = Uri.parse(_iframeUrl!);
    if ((url.isScheme('http') || url.isScheme('https')) &&
        url.host.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EligibilityCheckWebView(
            url: "$url",
            title: "Eligibility Check",
          ),
        ),
      );
    } else {
      throw SDKError(
        code: 'URL_LAUNCH_FAILED',
        message: 'Could not launch eligibility check URL',
      );
    }
  }

  void dispose() {
    _eventController.close();
  }
}
