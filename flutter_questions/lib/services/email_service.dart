import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/confirmation_screen.dart';

class EmailService {
  static String sanitizeInput(String input) {
    return parse(input).documentElement?.text ?? '';
  }

  static Future<void> sendEmail({
    required String topic,
    required String email,
    required String message,
    required String toEmail,
    required BuildContext context,
  }) async {
    // Sanitize inputs
    String sanitizedTopic = sanitizeInput(topic);
    String sanitizedEmail = sanitizeInput(email);
    String sanitizedMessage = sanitizeInput(message);
    String sanitizedToEmail = sanitizeInput(toEmail);

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final serviceId = dotenv.env['SERVICE_ID'];
    final templateId = dotenv.env['TEMPLATE_ID'];
    final userId = dotenv.env['USER_ID'];

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "service_id": "$serviceId",
          "template_id": "$templateId",
          "user_id": "$userId",
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