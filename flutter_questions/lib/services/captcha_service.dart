import 'dart:math';

class CaptchaService {
  static final Random _random = Random();

  // Generate a random string of 5 to 7 letters
  static String generateCaptcha() {
    const characters = 'ABCDEFGHJKLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789';
    int length = 5 + _random.nextInt(3); // Random length between 5 and 7
    return String.fromCharCodes(
      Iterable.generate(length, (_) => characters.codeUnitAt(_random.nextInt(characters.length))),
    );
  }

  // Validate the CAPTCHA
  static bool validateCaptcha(String input, String captcha) {
    return input == captcha;
  }
}