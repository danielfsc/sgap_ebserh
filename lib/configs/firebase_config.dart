import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const _apiKey = "AIzaSyB0kt9-kzTyDEj3NmYvJjxj8H8bTMIPLvA";
  static const _authDomain = "sgap-ebserh.firebaseapp.com";
  static const _projectId = "sgap-ebserh";
  static const _storageBucket = "sgap-ebserh.appspot.com";
  static const _messagingSenderId = "888498570415";
  static const _appId = "1:888498570415:web:3987818b3ec5014628c05a";

//Make some getter functions
  String get apiKey => _apiKey;
  String get authDomain => _authDomain;
  String get projectId => _projectId;
  String get storageBucket => _storageBucket;
  String get messagingSenderId => _messagingSenderId;
  String get appId => _appId;
}

FirebaseOptions myFirebaseOptions = const FirebaseOptions(
  apiKey: "AIzaSyB0kt9-kzTyDEj3NmYvJjxj8H8bTMIPLvA",
  authDomain: "sgap-ebserh.firebaseapp.com",
  projectId: "sgap-ebserh",
  storageBucket: "sgap-ebserh.appspot.com",
  messagingSenderId: "888498570415",
  appId: "1:888498570415:web:74fba768b1e5828d28c05a",
  measurementId: "G-EF34XJYECJ",
);
