import 'package:flutter/material.dart';
import '../widgets/email_form.dart';

class EmailWebScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escriba su pregunta y escoja el topico al que pertenece abajo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EmailForm(),
      ),
    );
  }
}