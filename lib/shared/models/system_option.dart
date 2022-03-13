import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SystemOption {
  String name;
  bool multiple;
  List<dynamic> data;

  SystemOption({
    required this.name,
    required this.multiple,
    required this.data,
  });

  updateData({String? text, String? symbol, int? index}) {
    if (index == null) {
      data.add({'text': text, 'symbol': symbol});
    } else {
      data[index] = {'text': text, 'symbol': symbol};
    }
  }

  deleteData(index) {
    data.removeAt(index);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'multiple': multiple,
      'data': data.toList(),
    };
  }

  save(String docId) {
    FirebaseFirestore.instance.collection('system').doc(docId).update(toMap());
  }

  factory SystemOption.fromMap(
    Map<String, dynamic> map,
  ) {
    return SystemOption(
      name: map['name'] ?? '',
      multiple: map['multiple'] ?? false,
      data: List<dynamic>.from(map['data']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SystemOption.fromJson(String source) =>
      SystemOption.fromMap(json.decode(source));
}
