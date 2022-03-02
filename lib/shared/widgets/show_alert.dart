import 'package:flutter/material.dart';

Future<bool> showAlert(
  context, {
  String cancelTitle = 'Cancelar',
  String confirmTitle = 'Ok',
  String title = 'Alerta',
  String message = '',
}) async {
  Widget cancelButton = TextButton(
    child: Text(cancelTitle),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );

  Widget continueButton = TextButton(
    child: Text(confirmTitle),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  bool? out = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
  return out ?? false;
}
