import 'package:flutter/material.dart';

InputDecoration inputDecoration(
  String label, {
  String? suffix,
  String? hintText,
}) {
  return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: Colors.grey.shade900, width: 0.8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      labelText: label,
      suffix: suffix != null ? Text(suffix) : null,
      hintText: hintText);
}
