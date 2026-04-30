import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String url;

  const PaymentWebViewPage({super.key, required this.url});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() => isLoading = true);
              },
              onPageFinished: (String url) {
                setState(() => isLoading = false);
              },
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('payment-success')) {
                  final uri = Uri.parse(request.url);
                  final id = uri.queryParameters['appointmentId'];
                  _finishPayment(context, success: true, appointmentId: id);
                  return NavigationDecision.prevent;
                }

                if (request.url.contains('payment-failure')) {
                  _finishPayment(context, success: false);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  void _finishPayment(
    BuildContext context, {
    String? appointmentId,
    required bool success,
  }) {
    if (success && appointmentId != null) {
      context.pop(appointmentId);
    } else {
      context.pop(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Payment"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finishPayment(context, success: false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
