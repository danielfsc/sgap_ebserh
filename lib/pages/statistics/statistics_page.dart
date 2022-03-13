import 'package:flutter/material.dart';
import 'package:sgap_ebserh/pages/statistics/statistics_body.dart';
import 'package:sgap_ebserh/shared/pages/page_mask.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return const PageMask(body: StatisticsBody(), title: 'Estatística');
  }
}
