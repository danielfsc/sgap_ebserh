import 'package:flutter/material.dart';

double defaultCardWidth(context) =>
    MediaQuery.of(context).size.width * 0.9 > 400
        ? 400
        : MediaQuery.of(context).size.width * 0.9;