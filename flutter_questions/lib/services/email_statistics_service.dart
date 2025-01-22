/*import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EmailStatisticsService {
  static const String _fileName = 'email_statistics.json';

  // Get the file path
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // Read statistics from the file
  static Future<Map<String, dynamic>> _readStatistics() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        String content = await file.readAsString();
        return json.decode(content);
      }
    } catch (e) {
      print('Error reading statistics: $e');
    }
    return {}; // Return an empty map if there's an error or the file doesn't exist
  }

  // Write statistics to the file
  static Future<void> _writeStatistics(Map<String, dynamic> data) async {
    try {
      final file = await _getFile();
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error writing statistics: $e');
    }
  }

  // Update the email count for a topic in the current month
  static Future<void> updateStatistics(String topic) async {
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    Map<String, dynamic> statistics = await _readStatistics();
    if (!statistics.containsKey(yearMonth)) {
      statistics[yearMonth] = {};
    }

    if (!statistics[yearMonth].containsKey(topic)) {
      statistics[yearMonth][topic] = 0;
    }

    statistics[yearMonth][topic] += 1;

    await _writeStatistics(statistics);
  }

  // Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    return await _readStatistics();
  }
}*/