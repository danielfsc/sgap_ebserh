import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Profile {
  String role;
  String email;
  String crm;
  String photoURL;
  String preceptors;
  String name;
  Timestamp admission;

  Profile({
    required this.role,
    required this.email,
    required this.crm,
    required this.photoURL,
    required this.preceptors,
    required this.name,
    required this.admission,
  });

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'email': email,
      'crm': crm,
      'photoURL': photoURL,
      'preceptors': preceptors,
      'name': name,
      'admission': admission,
    };
  }

  void save() {
    FirebaseFirestore.instance.collection("users/").doc(email).update(toMap());
  }

  factory Profile.fromMapPlusCredential(map, User credential) {
    return Profile(
      role: map['role'] ?? '',
      email: credential.email ?? '',
      crm: map['crm'] ?? '',
      photoURL: credential.photoURL ?? '',
      preceptors: map['preceptors'] ?? '',
      name: map['name'] ?? '',
      admission: map['admission'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
}
