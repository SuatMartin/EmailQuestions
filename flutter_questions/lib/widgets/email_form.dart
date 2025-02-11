import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/email_service.dart';
import 'package:http/http.dart' as http;

class EmailForm extends StatefulWidget {
  const EmailForm({super.key});

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();

  String? _selectedTopic;
  final List<String> _topics = [
    'Demografía/Poblacion/Censo', 
    'Economía', 
    'Salud', 
    'Geografía', 
    'Telecomunicaciones/Transportación/Carreteras',
    'Ambiental', 
    'Educación', 
    'Ciencia y Tecnología', 
    'Familia/Servicios Sociales', 
    'Justicia/Seguridad', 
    'Otros', 
    'Turismo', 
    'Cultura', 
    'Academias y Talleres'
  ];

  late final Map<String, String> _topicEmailMap;
  bool isCaptchaVerified = false;
  Timer? _timer;
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _topicEmailMap = {
      'Demografía/Poblacion/Censo': dotenv.env['DEMOGRAFIA_EMAIL'] ?? '',
      'Economía': dotenv.env['ECONOMIA_EMAIL'] ?? '',
      'Salud': dotenv.env['SALUD_EMAIL'] ?? '',
      'Geografía': dotenv.env['GEOGRAFIA_EMAIL'] ?? '',
      'Telecomunicaciones/Transportación/Carreteras': dotenv.env['TELECOMUNICACIONES_EMAIL'] ?? '',
      'Ambiental': dotenv.env['AMBIENTAL_EMAIL'] ?? '',
      'Educación': dotenv.env['EDUCACION_EMAIL'] ?? '',
      'Ciencia y Tecnología': dotenv.env['CIENCIA_TECHNOLOGIA_EMAIL'] ?? '',
      'Familia/Servicios Sociales': dotenv.env['FAMILIA_SERVICIOS_SOCIALES_EMAIL'] ?? '',
      'Justicia/Seguridad': dotenv.env['JUSTICIA_SEGURIDAD_EMAIL'] ?? '',
      'Otros': dotenv.env['OTROS_EMAIL'] ?? '',
      'Turismo': dotenv.env['TURISMO_EMAIL'] ?? '',
      'Cultura': dotenv.env['CULTURA_EMAIL'] ?? '',
      'Academias y Talleres': dotenv.env['ACADEMIAS_TALLERES_EMAIL'] ?? '',
    };
  }

  void _sendEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedTopic != null) {
        String toEmail = _topicEmailMap[_selectedTopic!]!;
        EmailService.sendEmail(
          topic: _selectedTopic!,
          email: _emailController.text,
          message: _messageController.text,
          name: _nameController.text,
          question: _questionController.text,
          toEmail: toEmail,
          context: context,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a topic')),
        );
      }
    }
  }

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

  // Function to show the reCAPTCHA WebView
  void _showRecaptchaWebView(BuildContext context) {
    FocusScope.of(context).unfocus();
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
                    _timer?.cancel();
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri("http://localhost:8000/recaptcha"),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    _startCaptchaPolling();
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedTopic,
            hint: Text('Select Topic'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTopic = newValue;
              });
            },
            validator: (value) => value == null ? 'Please select a topic' : null,
            items: _topics.map<DropdownMenuItem<String>>((String topic) {
              return DropdownMenuItem<String>(
                value: topic,
                child: Text(topic),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Your Name'),
            validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(labelText: 'Your Question'),
            validator: (value) => value!.isEmpty ? 'Please enter your question' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Your Email'),
            validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(labelText: 'Message'),
            maxLines: 4,
            validator: (value) => value!.isEmpty ? 'Please enter a message' : null,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showRecaptchaWebView(context),
            child: Text('Verify with reCAPTCHA'),
          ),
          SizedBox(height: 10),
          if (isCaptchaVerified)
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Send Email'),
            ),
        ],
      ),
    );
  }
}