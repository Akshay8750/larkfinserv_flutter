import 'package:larkfinserv_flutter/larkfinserv_flutter.dart';

class EligibilityCheckWebView extends StatefulWidget {
  final String url;
  final String title;

  const EligibilityCheckWebView({
    super.key,
    required this.url,
    this.title = "Eligibility Check",
  });

  @override
  State<EligibilityCheckWebView> createState() =>
      _EligibilityCheckWebViewState();
}

class _EligibilityCheckWebViewState extends State<EligibilityCheckWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF0F4089),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
