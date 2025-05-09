import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:js' as js;
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
  String? recaptchaToken;

  String? _selectedTopic;
  final List<String> _topics = [
    'Demografía, Población, Censo',
    'Economía',
    'Salud',
    'Geografía',
    'Telecomunicaciones, Transportación, Carreteras',
    'Ambiental',
    'Educación',
    'Ciencia y Tecnología',
    'Familia, Servicios Sociales',
    'Justicia, Seguridad',
    'Violencia',
    'Violencia de genero',
    'Turismo',
    'Cultura',
    'Academias y Talleres'
  ];

  late final Map<String, String> _topicEmailMap;
  bool isCaptchaVerified = false;
  Timer? _timer;

  final _honeypotNameController = TextEditingController(); // Honeypot field
  final _honeypotEmailController = TextEditingController(); // Honeypot field

  @override
  void initState() {
    super.initState();
    _topicEmailMap = {
      'Demografía, Población, Censo': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Economía': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Salud': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Geografía': 'suat.giray@estadisticas.pr',
      'Telecomunicaciones, Transportación, Carreteras': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Ambiental': 'suat.giray@estadisticas.pr',
      'Educación': 'suat.giray@estadisticas.pr',
      'Ciencia y Tecnología':'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Familia, Servicios Sociales': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Justicia, Seguridad': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Violencia': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Violencia de genero': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Turismo': 'suat.giray@estadisticas.pr,marcos.santana@estadisticas.pr',
      'Cultura': 'suat.giray@estadisticas.pr',
      'Academias y Talleres': 'suat.giray@estadisticas.pr',
    };
  }

  void _sendEmail() async {
  if (_honeypotNameController.text.isNotEmpty || _honeypotEmailController.text.isNotEmpty) {
    Navigator.of(context).pop();
    return;
  }

  if (_formKey.currentState?.validate() ?? false) {
    if (_selectedTopic != null) {
      if (recaptchaToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, complete el reCAPTCHA')),
        );
        return;
      }

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
        SnackBar(content: Text('Correo enviado exitosamente')),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione un tema')),
      );
    }
  }
}

  void _showRecaptcha() async {
  try {
    final jsToken = js.context.callMethod('getRecaptchaToken', ['submit']);
    if (jsToken is Future) {
      final token = await jsToken; // Wait for reCAPTCHA token
      if (token is String) {
        setState(() {
          recaptchaToken = token;
          isCaptchaVerified = true; // Enable submit button
        });
      }
    }
  } catch (e) {
    print("Error in reCAPTCHA: $e");
  }
}

void _verifyCaptcha() {
  String? token = js.context.callMethod('getCaptchaResponse');
  if (token != null && token.isNotEmpty) {
    setState(() {
      recaptchaToken = token;
      isCaptchaVerified = true; // Enable submit button
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor complete el reCAPTCHA')),
    );
  }
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedTopic,
                    decoration: InputDecoration(
                      labelText: 'Seleccione un tema',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 13, 13, 13)),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTopic = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un tema' : null,
                    items: _topics.map<DropdownMenuItem<String>>((String topic) {
                      return DropdownMenuItem<String>(
                        value: topic,
                        child: Text(topic),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre y Apellido (Ingrese su nombre)',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 13, 13, 13)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Su Correo Electrónico (Ingrese un correo válido)',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 13, 13, 13)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese un correo válido' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Tópico (Ingrese el tópico de su pregunta)',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 13, 13, 13)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese el tópico de su pregunta' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Escriba su pregunta aquí (Incluya el mayor detalle posible)',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 13, 13, 13)),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty ? 'Ingrese su pregunta detallada' : null,
                  ),
                  // Honeypot fields (hidden from the user)
                  Visibility(
                    visible: false,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _honeypotNameController,
                          decoration: InputDecoration(labelText: 'Honeypot: Nombre'),
                        ),
                        TextFormField(
                          controller: _honeypotEmailController,
                          decoration: InputDecoration(labelText: 'Honeypot: Email'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _verifyCaptcha,
                          child: Text('Verificar reCAPTCHA'),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: isCaptchaVerified ? _sendEmail : null,
                          child: Text('Enviar Correo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}