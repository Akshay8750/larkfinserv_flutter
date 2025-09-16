import 'package:flutter/material.dart';
import 'package:larkfinserv_flutter/larkfinserv_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LarkFinServ SDK Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final sdk = LarkFinServSDK();

  @override
  void initState() {
    super.initState();

    // Initialize SDK with dummy values (replace with real keys for testing)
    sdk.initialize(
      PartnerConfig(
        partnerId: "demo-partner",
        partnerName: "Demo Partner",
        apiKey: "your-api-key",
        apiSecret: "your-api-secret",
        environment: "sandbox", // or "production"
      ),
    );

    // Listen for SDK events
    sdk.events.listen((event) {
      debugPrint("SDK Event: ${event.type}");
      if (event.data != null) {
        debugPrint("Event data: ${event.data}");
      }

      if (event.type == SDKEventType.eligibilityResult) {
        final result = event.data?['result'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eligibility Result: $result")),
        );
      }

      if (event.type == SDKEventType.error) {
        final error = event.data?['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    });
  }

  @override
  void dispose() {
    sdk.dispose();
    super.dispose();
  }

  void _openPopupMode() async {
    try {
      await sdk.openEligibilityCheck(SDKMode.popup);
    } catch (e) {
      debugPrint("Popup mode failed: $e");
    }
  }

  void _openEmbeddedMode() {
    try {
      final controller = sdk.createWebViewController();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Eligibility Check (Embedded)")),
            body: WebViewWidget(controller: controller),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Embedded mode failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LarkFinServ SDK Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _openPopupMode,
              child: const Text("Open Eligibility Check (Popup Mode)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openEmbeddedMode,
              child: const Text("Open Eligibility Check (Embedded WebView)"),
            ),
          ],
        ),
      ),
    );
  }
}
