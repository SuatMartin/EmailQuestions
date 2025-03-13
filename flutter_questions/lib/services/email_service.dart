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

  static final String endpoint = "http://localhost:3000/send-email";
  static final String countEndpoint = "http://localhost:3000/increment-email-count";

  /// Send email request
  static Future<void> sendEmail({
    required String topic,
    required String email,
    required String message,
    required String toEmail,
    required String name,
    required String question,
    required BuildContext context,
  }) async {
    final backendUrl = Uri.parse(endpoint);

    try {
      final response = await http.post(
        backendUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "topic": sanitizeInput(topic),
          "email": sanitizeInput(email),
          "message": sanitizeInput(message),
          "toEmail": sanitizeInput(toEmail),
          "name": sanitizeInput(name),
          "question": sanitizeInput(question),
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['success'])),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );

        // After sending email successfully, increment the topic count
        await _incrementTopicCount(topic);
      } else {
        throw Exception(responseData['error']);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  /// Increment topic count
  static Future<void> _incrementTopicCount(String topic) async {
    final nodeJsUrl = Uri.parse(countEndpoint);

    try {
      final response = await http.post(
        nodeJsUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"topic": sanitizeInput(topic)}),
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