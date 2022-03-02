import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'configs/routes.dart';

class MainWidget extends StatelessWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VRouter(
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      initialUrl: '/',
      title: 'SGAP - UFSC',
      routes: vRoutes,
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return AnimatedBuilder(
  //     animation: AppController.instance,
  //     builder: (context, child) {
  //       return MaterialApp(
  //         theme: ThemeData(
  //           primarySwatch: Colors.blueGrey,
  //         ),
  //         initialRoute: '/',
  //         routes: routes,
  //         title: 'SGAP - UFSC',
  //       );
  //     },
  //   );
  // }
}
