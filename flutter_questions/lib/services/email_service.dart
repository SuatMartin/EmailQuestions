import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/confirmation_screen.dart';
import 'dart:convert';

class EmailService {
  static String sanitizeInput(String input) {
    return parse(input).documentElement?.text ?? '';
  }

  static Future<void> sendEmail({
  required String topic,
  required String email,
  required String message,
  required String toEmail,
  required String name,
  required String question,
  required BuildContext context,
}) async {
  // Sanitize inputs
  String sanitizedTopic = sanitizeInput(topic);
  String sanitizedEmail = sanitizeInput(email);
  String sanitizedMessage = sanitizeInput(message);
  String sanitizedToEmail = sanitizeInput(toEmail);
  String sanitizedName = sanitizeInput(name);
  String sanitizedQuestion = sanitizeInput(question);

  final emailJsUrl = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final director = dotenv.env['directorEmail']; // Director's email
  final serviceId = dotenv.env['SERVICE_ID'];
  final templateId = dotenv.env['TEMPLATE_ID']; // Template for the first email
  final templateIdToDirector = dotenv.env['TEMPLATE_ID2']; // Template for the second email
  final userId = dotenv.env['USER_ID'];

  try {
    // Send first email (to the recipient)
    final emailResponse = await http.post(
      emailJsUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": userId,
        "template_params": {
          "topic": sanitizedTopic,
          "name": sanitizedName,
          "question": sanitizedQuestion,
          "from_email": sanitizedEmail,
          "message": sanitizedMessage,
          "to_email": sanitizedToEmail,
        }
      }),
    );

    if (emailResponse.statusCode == 200) {
      // If first email was sent successfully, send email to the director
      final directorEmailResponse = await http.post(
        emailJsUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "service_id": serviceId,
          "template_id": templateIdToDirector,
          "user_id": userId,
          "template_params": {
            "topic": sanitizedTopic,
            "director": director, // Sending email to the director
            "message": sanitizedMessage,
            "to_email": sanitizedToEmail,
          }
        }),
      );

      if (directorEmailResponse.statusCode == 200) {
        // If both emails were sent, increment the topic count
        await _incrementTopicCount(sanitizedTopic);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );
      } else {
        throw Exception('Failed to send email to the director: ${directorEmailResponse.body}');
      }
    } else {
      throw Exception('Failed to send the first email: ${emailResponse.body}');
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $error')),
    );
  }
}

  static Future<void> _incrementTopicCount(String topic) async {
  final nodeJsUrl = Uri.parse('http://localhost:3000/increment-email-count'); // Backend URL

  try {
    final response = await http.post(
      nodeJsUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"topic": topic}),
    );

    if (response.statusCode == 200) {
      print('Successfully incremented count for topic: $topic');
    } else {
      print('Failed to increment count. Response: ${response.body}');
    }
  } catch (error) {
    print('Error incrementing topic count: $error');
  }
}
}