# Lark FinServ Flutter SDK

A Flutter SDK for integrating Lark FinServ's loan eligibility check functionality into your Flutter applications.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  larkfinserv_flutter:
    path: ../larkfinserv_flutter # Adjust path as needed
```

## Usage

### 1. Initialize the SDK

First, initialize the SDK with your configuration:

```dart
import 'package:larkfinserv_flutter/larkfinserv_flutter.dart';

// Create SDK instance
final sdk = LarkFinServSDK();

// Initialize with configuration
try {
  await sdk.initialize(PartnerConfig(
    apiKey: 'your_api_key',
    apiSecret: 'your_api_secret',
    environment: 'sandbox', // or 'production'
    phoneNumber: '+1234567890', // optional
    theme: ThemeConfig(
      primaryColor: '#FF5733',
      secondaryColor: '#33FF57',
      fontFamily: 'Roboto',
      logoUrl: 'https://your-logo-url.com/logo.png',
      name: 'Your App Name',
    ),
  ));
} catch (e) {
  print('SDK initialization failed: $e');
}
```

### 2. Popup Mode

To open the eligibility check in a popup window:

```dart
try {
  await sdk.openEligibilityCheck(SDKMode.popup);
} catch (e) {
  print('Failed to open eligibility check: $e');
}
```

### 3. Inline Mode

To embed the eligibility check within your app:

```dart
class MyApp extends StatelessWidget {
  final sdk = LarkFinServSDK();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Loan Eligibility Check')),
        body: Center(
          child: Container(
            width: 500,
            height: 700,
            child: EligibilityCheckWidget(
              sdk: sdk,
              onEvent: (event) {
                switch (event.type) {
                  case SDKEventType.ready:
                    print('SDK is ready');
                    break;
                  case SDKEventType.eligibilityResult:
                    final result = event.data?['result'];
                    print('Eligibility Result: $result');
                    break;
                  case SDKEventType.error:
                    final error = event.data?['error'];
                    print('Error: ${error?.message}');
                    break;
                  case SDKEventType.close:
                    print('SDK closed');
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4. Event Handling

The SDK provides various events that you can listen to:

```dart
sdk.events.listen((event) {
  switch (event.type) {
    case SDKEventType.ready:
      // SDK is ready to use
      break;
    case SDKEventType.eligibilityResult:
      // Handle eligibility result
      final result = event.data?['result'];
      break;
    case SDKEventType.error:
      // Handle error
      final error = event.data?['error'];
      break;
    case SDKEventType.close:
      // Handle SDK close
      break;
    case SDKEventType.initiated:
      // SDK initialization started
      break;
    case SDKEventType.closeFrame:
      // Frame closed
      break;
  }
});
```

### 5. Error Handling

The SDK provides detailed error information:

```dart
try {
  await sdk.initialize(config);
} catch (e) {
  if (e is SDKError) {
    print('Error Code: ${e.code}');
    print('Error Message: ${e.message}');
  }
}
```

### 6. Cleanup

Don't forget to dispose of the SDK when you're done:

```dart
@override
void dispose() {
  sdk.dispose();
  super.dispose();
}
```

## Configuration Options

### PartnerConfig

| Parameter   | Type        | Required | Description               |
| ----------- | ----------- | -------- | ------------------------- |
| apiKey      | String      | Yes      | Your API key              |
| apiSecret   | String      | Yes      | Your API secret           |
| environment | String      | No       | 'sandbox' or 'production' |
| partnerId   | String      | No       | Your partner ID           |
| partnerName | String      | No       | Your partner name         |
| phoneNumber | String      | No       | User's phone number       |
| theme       | ThemeConfig | No       | UI customization options  |

### ThemeConfig

| Parameter      | Type   | Description                   |
| -------------- | ------ | ----------------------------- |
| primaryColor   | String | Primary color in hex format   |
| secondaryColor | String | Secondary color in hex format |
| fontFamily     | String | Font family name              |
| logoUrl        | String | URL of your logo              |
| name           | String | Your app name                 |

## Error Codes

| Code                  | Description                        |
| --------------------- | ---------------------------------- |
| INVALID_CONFIG        | Missing or invalid configuration   |
| INITIALIZATION_FAILED | Failed to initialize SDK           |
| SDK_NOT_INITIALIZED   | SDK not initialized before use     |
| URL_LAUNCH_FAILED     | Failed to launch URL in popup mode |
| WEBVIEW_ERROR         | Error in WebView                   |

## Platform Support

- iOS 11.0+
- Android API level 21+
- Web (with limitations)

## Dependencies

- webview_flutter: ^4.4.2
- url_launcher: ^6.2.2
- http: ^1.1.0
- shared_preferences: ^2.2.2
