import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ShowUserModel {
  String photoURL;
  String name;
  String crm;
  String email;
  String role;
  Timestamp admission;
  String? preceptor;

  ShowUserModel({
    required this.photoURL,
    required this.name,
    required this.crm,
    required this.email,
    required this.role,
    required this.admission,
    this.preceptor,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoURL': photoURL,
      'name': name,
      'crm': crm,
      'email': email,
      'role': role,
      'admission': admission,
      'preceptor': preceptor,
    };
  }

  factory ShowUserModel.fromDoc(doc) {
    Map<String, dynamic> map = doc.data();
    return ShowUserModel(
      photoURL: map['photoURL'] ?? '',
      name: map['name'] ?? '',
      crm: map['crm'] ?? '',
      email: doc.id ?? '',
      role: map['role'] ?? '',
      admission: map['admission'] ?? '',
      preceptor: map['preceptor'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  // factory ShowUserModel.fromJson(String source) =>
  //     ShowUserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShowUserModel(photoURL: $photoURL, name: $name, crm: $crm, email: $email, role: $role, admission: $admission)';
  }
}
