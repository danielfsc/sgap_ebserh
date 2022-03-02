import 'package:flutter/material.dart';

Widget loading() {
  return Center(
    child: Column(
      children: const [
        CircularProgressIndicator(),
        Text('Carregando...'),
      ],
    ),
  );
}

Widget semregistro(String message) {
  return Center(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(message),
      ),
    ),
  );
}
