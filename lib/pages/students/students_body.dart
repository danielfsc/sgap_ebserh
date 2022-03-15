import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/controllers/app_controller.dart';
import 'package:sgap_ebserh/pages/students/student_card.dart';

import '../../shared/widgets/empty_loading.dart';

class StudentsBody extends StatefulWidget {
  const StudentsBody({Key? key}) : super(key: key);

  @override
  State<StudentsBody> createState() => _StudentsBodyState();
}

class _StudentsBodyState extends State<StudentsBody> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: StreamBuilder(
            stream: getStudents(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return loading();
              } else if (snapshot.data.docs.length == 0) {
                return const Text(
                    'Você não possui nenhum estudante para selecionar.');
              }
              return studentsList(context, snapshot.data.docs);
            }),
      ),
    );
  }

  Widget studentsList(
      BuildContext context, List<QueryDocumentSnapshot> students) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: students
          .map<Widget>(
              (doc) => StudentCard(user: doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Stream getStudents() {
    return usersCollection
        .where('preceptors', isEqualTo: AppController.instance.email)
        .where('archived', isEqualTo: false)
        .snapshots();
  }
}
