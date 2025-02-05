import 'package:flutter/material.dart';
import '../widgets/email_form.dart';

class EmailWebScreen extends StatelessWidget {
  const EmailWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escriba su pregunta y escoja el topico al que pertenece abajo'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[100],
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EmailForm(),
      ),
    );
  }
}