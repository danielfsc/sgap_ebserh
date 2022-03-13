import 'package:flutter/material.dart';
import 'package:sgap_ebserh/pages/statistics/statistics_body.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatística')),
      body: const StatisticsBody(),
    );
  }
}
