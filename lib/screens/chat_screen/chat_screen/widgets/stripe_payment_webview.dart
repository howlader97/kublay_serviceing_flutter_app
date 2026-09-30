import 'package:flutter/material.dart';
import 'package:belwork/constant/app_colors.dart';
import 'package:belwork/widgets/texts/app_text.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripePaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const StripePaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
  });

  static Future<bool?> show(BuildContext context, {required String checkoutUrl}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StripePaymentWebViewScreen(checkoutUrl: checkoutUrl),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<StripePaymentWebViewScreen> createState() =>
      _StripePaymentWebViewScreenState();
}

class _StripePaymentWebViewScreenState
    extends State<StripePaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progress = progress;
                _isLoading = progress < 100;
              });
            }
          },
          onPageStarted: (url) {
            _checkPaymentRedirect(url);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkPaymentRedirect(url);
          },
          onNavigationRequest: (request) {
            if (_checkPaymentRedirect(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _checkPaymentRedirect(String url) {
    final lower = url.toLowerCase();
    // Check for success indicators
    if (lower.contains('success') ||
        lower.contains('payment-success') ||
        lower.contains('return_url') ||
        lower.contains('status=paid') ||
        lower.contains('status=success') ||
        lower.contains('checkout/success')) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return true;
    }

    // Check for cancel indicators
    if (lower.contains('cancel') ||
        lower.contains('payment-cancel') ||
        lower.contains('status=cancelled') ||
        lower.contains('checkout/cancel')) {
      if (mounted) {
        Navigator.of(context).pop(false);
      }
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const AppText(
          text: 'Stripe Payment',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.instance.primary,
                  ),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
