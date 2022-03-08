import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/models/profile.dart';
// import 'package:teacher_helper/controllers/authentication.dart';

class AppController extends ChangeNotifier {
  static AppController instance = AppController._();
  bool isDark = false;
  bool isLeftHanded = true;

  User? _user;

  Profile? _profile;

  Profile? get profile {
    return _profile;
  }

  User? get user {
    return _user;
  }

  User? getUser(BuildContext context) {
    if (_user == null) {}

    return user;
  }

  Future<void> setUser(User? user) async {
    if (user == null) {
      _user = null;
      _profile = null;
      return;
    }
    _user = user;
    await setUserProfile(user);
  }

  Future<void> setUserProfile(user) async {
    dynamic profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .get();

    _profile = Profile.fromMapPlusCredential(profile.data(), _user!);
    if (_user!.photoURL != profile.data()['photoURL']) {
      _profile!.photoURL = _user!.photoURL!;
    }
    if (_profile!.name.isEmpty) {
      _profile!.name = _user!.displayName!;
    }
    _profile!.save();
    // _profile!.checkName(profile.data(), _user!);
  }

  String get email {
    if (_user != null) {
      return _user!.email ?? '';
    }
    return '';
  }

  bool get isLoggedIn {
    return _user != null;
  }

  changeHand() {
    isLeftHanded = !isLeftHanded;
    notifyListeners();
  }

  changeTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDark = !isDark;
    prefs.setBool('isDark', isDark);
    notifyListeners();
  }

  Future<bool> _getInitialDark() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isDark') == true;
    } catch (e) {
      return false;
    }
  }

  AppController._() {
    _getInitialDark().then((value) {
      isDark = value;
      notifyListeners();
    });
  }

  // brightness() {
  //   return isDark ? Brightness.dark : Brightness.light;
  // }
}
