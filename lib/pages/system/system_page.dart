import './system_body.dart';
import 'package:flutter/material.dart';

import '../../shared/pages/page_mask.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({Key? key}) : super(key: key);

  @override
  _SystemPageState createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  @override
  Widget build(BuildContext context) {
    return const PageMask(
      body: SystemBody(),
      title: 'Variáveis do Sistema',
    );
  }
}
