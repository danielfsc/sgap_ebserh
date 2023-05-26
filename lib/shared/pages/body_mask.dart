import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../controllers/app_controller.dart';

class BodyMask extends StatefulWidget {
  final String title;
  final Widget body;
  final Widget? floatingButton;
  final FloatingActionButtonLocation? floatingButtonLocation;
  const BodyMask(
      {Key? key,
      required this.body,
      required this.title,
      this.floatingButton,
      this.floatingButtonLocation})
      : super(key: key);

  @override
  State<BodyMask> createState() => _BodyMaskState();
}

class _BodyMaskState extends State<BodyMask> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _redirectTo,
      child: Scaffold(
        appBar: AppBar(
            title: Text(widget.title), leading: const MenuButtonWidget()),
        body: widget.body,
        floatingActionButton: widget.floatingButton,
        floatingActionButtonLocation:
            widget.floatingButtonLocation ?? _floatButtonPosition(),
      ),
    );
  }

  Future<bool> _redirectTo() async {
    if (ModalRoute.of(context) != null &&
        ModalRoute.of(context)!.settings.name != '/home') {
      Navigator.of(context).popAndPushNamed('/');
    }
    return false;
  }

  _floatButtonPosition() {
    return AppController.instance.isLeftHanded
        ? FloatingActionButtonLocation.endFloat
        : FloatingActionButtonLocation.endFloat;
  }
}

class MenuButtonWidget extends StatelessWidget {
  const MenuButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        // log('Abrir o menu');
        ZoomDrawer.of(context)!.open();
      },
    );
  }
}
