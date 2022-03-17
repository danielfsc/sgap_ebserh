import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'configs/firebase_config.dart';
import 'main_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FirebaseFirestore.instance.enablePersistence();
  await Firebase.initializeApp(
    options: myFirebaseOptions,
  );

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MainWidget());
}
