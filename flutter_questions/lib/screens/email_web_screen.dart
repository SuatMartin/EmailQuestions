import 'package:flutter/material.dart';
import '../widgets/email_form.dart';

class EmailWebScreen extends StatelessWidget {
  const EmailWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escriba su pregunta y escoja el tema'),
        centerTitle: true,
        backgroundColor: Colors.green[800], // Dark green app bar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              '../../assets/IEPR.png',
              height: 80,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 9, 58, 114), // Solid blue background for the body
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: EmailForm(),
        ),
      ),
    );
  }
}