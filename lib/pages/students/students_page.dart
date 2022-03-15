import 'package:flutter/material.dart';
import 'package:sgap_ebserh/pages/students/students_body.dart';
import 'package:sgap_ebserh/shared/pages/page_mask.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageMask(
      title: 'Meus Estudantes',
      body: StudentsBody(),
    );
  }
}
