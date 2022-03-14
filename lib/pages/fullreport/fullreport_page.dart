import 'package:flutter/material.dart';
import 'package:sgap_ebserh/shared/pages/page_mask.dart';

import 'fullreport_body.dart';

class FullReportPage extends StatelessWidget {
  const FullReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageMask(
      title: 'Relatório',
      body: FullReportBody(),
    );
  }
}
