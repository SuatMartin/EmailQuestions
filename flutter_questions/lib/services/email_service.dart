import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../screens/confirmation_screen.dart';

class EmailService {
  static const _serviceId = 'service_nwam7ai';
  static const _templateId = 'template_3vdppqw';
  static const _userId = 'VY3AWwYnUnUGPYubO';

  // Function to sanitize user input to prevent harmful scripts
  static String sanitizeInput(String input) {
    // Parse the input and remove any HTML tags (script injections, etc.)
    return parse(input).documentElement?.text ?? '';
  }

  static Future<void> sendEmail({
    required String topic,
    required String email,
    required String message,
    required String toEmail,
    required BuildContext context,
  }) async {
    // Sanitize inputs to prevent harmful scripts
    String sanitizedTopic = sanitizeInput(topic);
    String sanitizedEmail = sanitizeInput(email);
    String sanitizedMessage = sanitizeInput(message);
    String sanitizedToEmail = sanitizeInput(toEmail);

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "service_id": "$_serviceId",
          "template_id": "$_templateId",
          "user_id": "$_userId",
          "template_params": {
            "topic": "$sanitizedTopic",
            "from_email": "$sanitizedEmail",
            "message": "$sanitizedMessage",
            "to_email": "$sanitizedToEmail"
          }
        }
        ''',
      );

      if (response.statusCode == 200) {
        // Navigate to the confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );
      } else {
        throw Exception('Failed to send email: ${response.body}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }
}