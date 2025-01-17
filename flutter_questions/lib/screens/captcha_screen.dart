import 'package:flutter/material.dart';
import '../widgets/captcha_display.dart';
import '../services/captcha_service.dart';
import 'email_web_screen.dart';

class CaptchaScreen extends StatefulWidget {
  @override
  _CaptchaScreenState createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends State<CaptchaScreen> {
  late String _captcha;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    _captcha = CaptchaService.generateCaptcha();
    setState(() {});
  }

  void _validateCaptcha(BuildContext context) {
    if (CaptchaService.validateCaptcha(_controller.text, _captcha)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmailWebScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CAPTCHA incorrecto. Inténtelo de nuevo.')),
      );
      _controller.clear();
      _generateCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificación de CAPTCHA'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Por favor, ingrese el siguiente CAPTCHA para continuar:',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CaptchaDisplay(captcha: _captcha),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ingrese el CAPTCHA',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _validateCaptcha(context),
              child: Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}