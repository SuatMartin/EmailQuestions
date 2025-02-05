import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

class CaptchaWebViewScreen extends StatefulWidget {
  const CaptchaWebViewScreen({super.key});

  @override
  _CaptchaWebViewScreenState createState() => _CaptchaWebViewScreenState();
}

class _CaptchaWebViewScreenState extends State<CaptchaWebViewScreen> {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }

  // This is the function Flutter will call when the token is sent from the WebView.
  void _verifyToken(String token) {
    log('reCAPTCHA Token received: $token');
    // You can now send the token to your server for verification.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google reCAPTCHA'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(Uri.dataFromString(
            '''<html><body>
                <form action="javascript:void(0)">
                  <div class="g-recaptcha" data-sitekey="6LcNj8sqAAAAAM3JJ-g5ricmsu2MMZ4F30puZe3V" data-callback="onSubmit"></div>
                  <button type="submit">Submit</button>
                </form>
              </body></html>''', 
            mimeType: 'text/html', 
            encoding: Encoding.getByName('utf-8')
          )),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        onLoadStop: (controller, url) {
          // Inject the handler to communicate with Flutter when the reCAPTCHA is completed
          controller.addJavaScriptHandler(
            handlerName: 'verifyToken',
            callback: (args) {
              _verifyToken(args[0]);
            },
          );
        },
      ),
    );
  }
}