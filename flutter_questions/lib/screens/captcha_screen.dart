/*import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'email_web_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaptchaScreen extends StatefulWidget {
  @override
  _CaptchaScreenState createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  InAppWebViewController? _webViewController;
  bool isCaptchaVerified = false;
  Timer? _timer;

  // Function to check CAPTCHA status from the Node.js server
  Future<void> _checkCaptchaStatus() async {
  try {
    final uri = Uri.parse("http://localhost:8000/captcha-status");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result["success"] == true) {
        setState(() {
          isCaptchaVerified = true;
        });
        log("✅ CAPTCHA verified via API");

        // Stop polling once verified
        _timer?.cancel();
      }
    }
  } catch (e) {
    log("⚠️ Error checking CAPTCHA status: $e");
  }
}

  // Function to start polling the CAPTCHA verification API
  void _startCaptchaPolling() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkCaptchaStatus();
    });
  }

  // Function to display the WebView with the reCAPTCHA
  void _showRecaptchaWebView(BuildContext context) {
  FocusScope.of(context).unfocus(); // Dismiss keyboard if open
  showModalBottomSheet(
    isDismissible: false,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 700,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _timer?.cancel(); // Stop polling on close
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("http://localhost:8000/recaptcha"), // Load from Node.js server
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  _startCaptchaPolling(); // Start checking if CAPTCHA passed
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  void dispose() {
    _timer?.cancel(); // Cleanup when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify CAPTCHA'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[100],
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _showRecaptchaWebView(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Verify with reCAPTCHA'),
            ),
            SizedBox(height: 20),
            if (isCaptchaVerified)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EmailWebScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.green,
                ),
                child: Text('Continue'),
              ),
          ],
        ),
      ),
    );
  }
}*/