import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sgap_ebserh/configs/widths.dart';
import 'package:vrouter/vrouter.dart';

import '../../controllers/authentication.dart';
import '../../shared/widgets/empty_loading.dart';
import '../../shared/widgets/snack_message.dart';
import 'google_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<FirebaseApp>? _auth;
  String? code;
  bool _isSigningIn = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _auth = Authentication.initializeFirebase(context: context);
    super.initState();
    // _email.text = "d.girardi@ufsc.br";
    // _password.text = "123456";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.topLeft,
            colors: [
              Colors.blueGrey.shade100,
              Colors.white,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Image.asset(
                          'assets/ufsc_logo.png',
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SGAP',
                        style: TextStyle(
                          color: Color(0xff1b51a2),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Sistema de Gerenciamento de Atividades Práticas',
                        style: TextStyle(
                          color: Color(0xff1b51a2),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: defaultCardWidth(context),
                        child: TextField(
                          controller: _email,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'E-mail',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: defaultCardWidth(context),
                        child: TextField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Senha',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isSigningIn
                          ? loading()
                          : ElevatedButton(
                              onPressed: () {
                                signingIn(
                                    context: context,
                                    email: _email.text,
                                    password: _password.text);
                              },
                              child: const Text('Entrar'),
                            ),
                      code == "wrong-password"
                          ? Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  requestPasswordChangeEmail(
                                      context: context, email: _email.text);
                                },
                                child: const Text('Recuperar senhar?'),
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                      FutureBuilder(
                        future: _auth,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Erro ao iniciar o Firebase');
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const GoogleLoginButton();
                          }
                          return loading();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            context.vRouter.to('/signup');
                            // Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('Cadastrar-se'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signingIn(
      {required BuildContext context,
      required String email,
      required String password}) {
    setState(() {
      _isSigningIn = true;
    });
    Authentication.signInWithEmail(
            context: context, email: _email.text, password: _password.text)
        .then((value) {
      if (value != null) {
        setState(() {
          code = value;
          _isSigningIn = false;
        });
      } else {
        Authentication.setUserAndGoToHome(context);
      }
    });
  }

  void requestPasswordChangeEmail(
      {required BuildContext context, required String email}) {
    Authentication.requestPasswordChangeEmail(email: email).then((result) {
      switch (result) {
        case null:
          snackMessage(context,
              message:
                  "E-mail enviado com sucesso. Pode ser que o e-mail tenha ido para sua caixa de SPAM.",
              color: Colors.green);
          break;
        case "unregistred":
          snackMessage(context,
              message:
                  "Este e-mail ainda não está nos nossos registros. Você já fez o cadastro?",
              color: Colors.red);
          break;
        default:
          snackMessage(context,
              message:
                  "Ops, teve um erro com o banco de dados. Tente de novo em alguns instantes.",
              color: Colors.red);
      }
    });
  }
}
