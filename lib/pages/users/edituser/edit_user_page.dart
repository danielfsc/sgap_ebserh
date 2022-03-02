import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/controllers/authentication.dart';
import 'package:sgap_ebserh/shared/widgets/date_form_field.dart';
import 'package:sgap_ebserh/shared/widgets/snack_message.dart';
import 'package:vrouter/vrouter.dart';
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class EditUser extends StatefulWidget {
  const EditUser({Key? key}) : super(key: key);

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();

  bool isLoadded = false;

  String? role;

  DateTime? pickedDate;

  final List<TextEditingController> _controller =
      List.generate(5, (i) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    handleUserEmail(context.vRouter.pathParameters['email']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Usuário'),
      ),
      body: _fullForm(context),
    );
  }

  Widget _fullForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              decoration: _decoration('Nome Completo'),
              controller: _controller[0],
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: _decoration('E-mail'),
              controller: _controller[1],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'O e-mail é obrigatório';
                }

                if (!value.contains('@')) {
                  return 'E-mail inválido!';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: _decoration('CRM'),
              controller: _controller[2],
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: _decoration('E-mail do preceptor'),
              controller: _controller[3],
            ),
            const SizedBox(height: 20),
            _admission(context),
            const SizedBox(height: 20),
            _selectRole(),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _save(context), child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }

  Future<void> handleUserEmail(String? email) async {
    if (email != null && isLoadded == false) {
      dynamic user = await FirebaseFirestore.instance
          .collection('users/')
          .doc(email)
          .get();

      setState(() {
        isLoadded = true;
        _controller[0].text = user.data()['name'] ?? '';
        _controller[1].text = user.id;
        _controller[2].text = user.data()['crm'] ?? '';
        _controller[3].text = user.data()['preceptors'] ?? '';
        role = user.data()['role'];
        pickedDate =
            DateTime.parse(user.data()['admission'].toDate().toString());
        _controller[4].text = DateFormat("dd MMM yyyy").format(pickedDate!);
      });
    }
    // return const AsyncSnapshot.withData(ConnectionState.done, null);
  }

  Future<void> _save(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (role == null) {
        snackMessage(context,
            message: "Você tem que atribuir um papel ao usuário",
            color: Colors.red);
        return;
      }
      if (context.vRouter.pathParameters['email'] == null &&
          await Authentication.checkEmailRegisterStatus(
                  email: _controller[1].text) !=
              "missing") {
        snackMessage(context,
            message: "Este e-mail já foi registrado!", color: Colors.red);
        return;
      }
      try {
        if (context.vRouter.pathParameters['email'] == null) {
          FirebaseFirestore.instance
              .collection('users/')
              .doc(_controller[1].text)
              .set({
            'name': _controller[0].text,
            'email': _controller[1].text,
            'crm': _controller[2].text,
            'preceptors': _controller[3].text,
            'admission': Timestamp.fromDate(pickedDate!),
            'role': role,
            'archived': false,
          });
        } else {
          FirebaseFirestore.instance
              .collection('users/')
              .doc(_controller[1].text)
              .update({
            'name': _controller[0].text,
            'email': _controller[1].text,
            'crm': _controller[2].text,
            'preceptors': _controller[3].text,
            'admission': Timestamp.fromDate(pickedDate!),
            'role': role,
            'archived': false,
          });
        }
        snackMessage(context,
            message: 'Usuário salvo com sucesso', color: Colors.green);
        // context.vRouter.to('/users');
        context.vRouter.pop();
      } on FirebaseException catch (e) {
        snackMessage(context, message: e.code, color: Colors.red);
      }
    }
  }

  Widget _admission(BuildContext context) {
    return DateTimeField(
      validator: (value) {
        if (value == null) {
          return 'A data de admissão é obrigatória';
        }

        return null;
      },
      format: DateFormat("dd MMM yyyy"),
      decoration: _decoration('Admissão'),
      controller: _controller[4],
      onShowPicker: (context, currentValue) async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2021),
          initialDate: (currentValue ?? DateTime.now()),
          lastDate: DateTime(2040),
        );
        if (date != null) {
          pickedDate = date;
        }
        return date;
      },
    );
  }

  Widget _selectRole() {
    List<Map<String, String?>> roles = [
      {'value': null, 'text': 'Escolha um papel'},
      {'value': 'student', 'text': 'Residente'},
      {'value': 'preceptor', 'text': 'Preceptor'},
      {'value': 'admin', 'text': 'Administrador'},
    ];

    return DropdownButton<String>(
      value: role,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.blueGrey),
      underline: Container(height: 2, color: Colors.blueGrey),
      onChanged: (String? newValue) {
        setState(() {
          role = newValue!;
        });
      },
      items: roles.map<DropdownMenuItem<String>>((role) {
        return DropdownMenuItem<String>(
          value: role['value'],
          child: Text('${role['text']}'),
        );
      }).toList(),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      labelText: label,
    );
  }
}
