import 'dart:html' as html;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/material.dart';

class RecaptchaWidget extends StatelessWidget {
  final Function(String) onVerified;

  RecaptchaWidget({required this.onVerified});

  @override
  Widget build(BuildContext context) {
    html.Element iframe = html.IFrameElement()
      ..src = "https://www.google.com/recaptcha/api.js"
      ..style.border = "none"
      ..style.height = "80px"
      ..style.width = "320px";

    return HtmlElementView(viewType: 'recaptcha-view');
  }
}