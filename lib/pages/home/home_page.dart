import './home_body.dart';
import 'package:flutter/material.dart';

import '../../shared/pages/page_mask.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageMask(
      title: 'Inicio',
      body: HomeBody(),
    );
  }
}
