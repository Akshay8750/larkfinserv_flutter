import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../larkfinserv_sdk.dart';
import '../types/sdk_types.dart';

class EligibilityCheckWidget extends StatefulWidget {
  final LarkFinServSDK sdk;
  final Function(SDKEvent)? onEvent;

  const EligibilityCheckWidget({
    Key? key,
    required this.sdk,
    this.onEvent,
  }) : super(key: key);

  @override
  State<EligibilityCheckWidget> createState() => _EligibilityCheckWidgetState();
}

class _EligibilityCheckWidgetState extends State<EligibilityCheckWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.sdk.createWebViewController();
    widget.sdk.events.listen((event) {
      if (widget.onEvent != null) {
        widget.onEvent!(event);
      }
      if (event.type == SDKEventType.ready) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
