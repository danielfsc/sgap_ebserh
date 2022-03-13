import 'package:flutter/material.dart';
import 'package:sgap_ebserh/pages/procedures/procedures_body.dart';

class ProceduresView extends StatelessWidget {
  const ProceduresView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procedimentos')),
      body: const ProceduresBody(),
    );
  }
}
