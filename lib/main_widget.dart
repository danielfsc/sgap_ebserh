import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'configs/routes.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VRouter(
      logs: VLogs.none,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      initialUrl: '/',
      title: 'SGAP - UFSC',
      routes: vRoutes,
    );
  }
}
