import 'package:flutter/material.dart';
import '../../shared/pages/page_mask.dart';
import 'package:sgap_ebserh/pages/procedures/procedures_body.dart';

class ProcedurePage extends StatefulWidget {
  const ProcedurePage({Key? key}) : super(key: key);

  @override
  State<ProcedurePage> createState() => _ProcedurePageState();
}

class _ProcedurePageState extends State<ProcedurePage> {
  @override
  Widget build(BuildContext context) {
    return const PageMask(
      title: 'Procedimentos',
      body: ProceduresBody(),
    );
  }
}
