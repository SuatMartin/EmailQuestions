import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/email_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Load email mappings from .env
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
          name: _nameController.text,  // Add name to email
          question: _questionController.text,  // Add question to email
          toEmail: toEmail,
          context: context,
        );
        // Show a success message
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
            validator: (value) {
              if (value == null) {
                return 'Please select a topic';
              }
              return null;
            },
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(labelText: 'Your Question'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your question';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Your Email'),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(labelText: 'Message'),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a message';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendEmail,
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }
}