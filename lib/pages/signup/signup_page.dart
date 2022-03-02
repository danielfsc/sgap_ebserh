import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import '../../controllers/authentication.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final List<TextEditingController> _controller =
      List.generate(4, (i) => TextEditingController());
  String? emailProblem;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(title: const Text('Cadastro')),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                TextFormField(
                  decoration: _decoration('Nome Completo'),
                  controller: _controller[0],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome é obrigatório';
                    }
                    return null;
                  },
                ),
                Focus(
                  child: TextFormField(
                    decoration: _decoration('E-mail'),
                    controller: _controller[1],
                    key: _emailKey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O e-mail é obrigatório';
                      }

                      if (!value.contains('@')) {
                        return 'E-mail inválido!';
                      }
                      if (emailProblem == 'missing') {
                        return 'Este e-mail precisa ser cadastrado pelo administrador, antes de você realizar o cadastro.';
                      }
                      if (emailProblem == "registred") {
                        return 'Este e-mail já foi cadastrado, use a recuperação de senha.';
                      }
                      return null;
                    },
                  ),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      String email = _controller[1].text;
                      _emailKey.currentState!.validate();
                      if (email.contains('@')) {
                        Authentication.checkEmailRegisterStatus(email: email)
                            .then((value) {
                          emailProblem = value;
                          setState(() {
                            _emailKey.currentState!.validate();
                          });
                        });
                      }
                    }
                  },
                ),
                TextFormField(
                  decoration: _decoration('CRM'),
                  controller: _controller[2],
                ),
                TextFormField(
                  decoration: _decoration('Senha'),
                  obscureText: true,
                  controller: _controller[3],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A senha é obrigatória';
                    }
                    return null;
                  },
                ),
                Center(
                  child: ElevatedButton(
                    child: const Text('Cadastrar-se'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Authentication.signUp(
                          name: _controller[0].text,
                          email: _controller[1].text,
                          crm: _controller[2].text,
                          password: _controller[3].text,
                        ).then((result) {
                          if (result == null) {
                            context.vRouter.to('/home');
                            // Navigator.of(context).popAndPushNamed('/home');
                          } else if (result == "email-already-in-use") {
                            setState(() {
                              emailProblem = "registred";
                              _emailKey.currentState!.validate();
                            });
                          }
                        });
                      } else {}
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
