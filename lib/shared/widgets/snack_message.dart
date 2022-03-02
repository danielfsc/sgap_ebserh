import 'package:flutter/material.dart';

void snackMessage(BuildContext context,
    {required String message, Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}
