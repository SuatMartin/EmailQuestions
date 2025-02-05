import 'package:flutter/material.dart';

class CaptchaDisplay extends StatelessWidget {
  final String captcha;

  const CaptchaDisplay({super.key, required this.captcha});

  @override
  Widget build(BuildContext context) {
    return Text(
      captcha,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}