import 'package:flutter/material.dart';

Widget loading() {
  return const Center(
    child: Column(
      children: [
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
