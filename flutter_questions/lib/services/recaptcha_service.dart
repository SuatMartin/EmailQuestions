import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecaptchaService {
  // Function to verify the token with your backend
  Future<bool> verifyToken(String token) async {
    final secretKey = dotenv.env['RECAPTCHA_SECRET_KEY'];
    if (secretKey == null) {
      print("❌ Secret Key not found!");
      return false;
    }

    final response = await http.post(
      Uri.parse('https://www.google.com/recaptcha/api/siteverify'),
      body: {
        'secret': secretKey,
        'response': token,
      },
    );

    // Check if the response is valid
    final data = json.decode(response.body);
    return data['success'] == true;
  }
}