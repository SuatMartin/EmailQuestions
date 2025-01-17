import 'package:flutter/material.dart';
import '../services/email_statistics_service.dart';

class EmailStatisticsScreen extends StatefulWidget {
  @override
  _EmailStatisticsScreenState createState() => _EmailStatisticsScreenState();
}

class _EmailStatisticsScreenState extends State<EmailStatisticsScreen> {
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    Map<String, dynamic> stats = await EmailStatisticsService.getStatistics();
    setState(() {
      _statistics = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Statistics'),
      ),
      body: _statistics.isEmpty
          ? Center(child: Text('No data available'))
          : ListView(
              children: _statistics.entries.map((entry) {
                String yearMonth = entry.key;
                Map<String, dynamic> topics = entry.value;

                return ExpansionTile(
                  title: Text(yearMonth),
                  children: topics.entries.map((topicEntry) {
                    return ListTile(
                      title: Text('${topicEntry.key}: ${topicEntry.value} emails'),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
    );
  }
}