import 'package:flutter/material.dart';

class IconMenu {
  final String value;
  final IconData icon;
  final bool isPublic;

  IconMenu(
    this.value,
    this.icon, {
    this.isPublic = true,
  });
}
