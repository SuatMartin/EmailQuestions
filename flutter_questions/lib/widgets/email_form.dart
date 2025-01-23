import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/email_service.dart';

class EmailForm extends StatefulWidget {
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedTopic;
  final List<String> _topics = ['General Inquiry', 'Support', 'Feedback', 'Others'];

  late final Map<String, String> _topicEmailMap;

  @override
  void initState() {
    super.initState();
    // Load email mappings from .env
    _topicEmailMap = {
      'General Inquiry': dotenv.env['GENERAL_INQUIRY_EMAILS'] ?? '',
      'Support': dotenv.env['SUPPORT_EMAIL'] ?? '',
      'Feedback': dotenv.env['FEEDBACK_EMAIL'] ?? '',
      'Others': dotenv.env['OTHERS_EMAIL'] ?? '',
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
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
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