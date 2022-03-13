import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vrouter/vrouter.dart';

import '../shared/widgets/snack_message.dart';
import 'app_controller.dart';

class Authentication {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<FirebaseApp> initializeFirebase(
      {required BuildContext context,
      String endPoint = '/home',
      bool changeRoute = true}) async {
    try {
      FirebaseApp firebaseApp = await Firebase.initializeApp();
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await AppController.instance.setUser(user);
        if (changeRoute) {
          context.vRouter.to(endPoint);
          // Navigator.of(context).popAndPushNamed(endPoint);
        }
      }

      return firebaseApp;
    } on Exception catch (_) {
      return await Firebase.initializeApp();
    }
  }

  static Future signInWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          snackMessage(context,
              message: "Este e-mail ainda não possui cadastro.",
              color: Colors.red);

          break;
        case "wrong-password":
          snackMessage(context,
              message:
                  "Senha Incorreta, tente novamente ou use a recuperação de senha.",
              color: Colors.red);

          break;
        default:
          snackMessage(context,
              message:
                  'Ops, houve um problema desconhecido. Tente novamente mais tarde',
              color: Colors.red);
      }

      return e.code;
    }
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        log(e.toString());
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            snackMessage(context,
                message:
                    'Essa conta já existe com outra credencial. Fale com o administrador.');
          } else if (e.code == 'invalid-credential') {
            snackMessage(context,
                message:
                    'Erro enquanto acessava sua credencial. Tente novamente.');
          }
        } catch (e) {
          snackMessage(context,
              message: 'Erro durante o acesso com o Google. Tente novamente.');
        }
      }
    }

    if (user != null &&
        await checkEmailRegisterStatus(email: user.email!) == "missing") {
      signOut(context: context);
      return null;
    }

    return user;
  }

  static Future<String?> signUp(
      {required String email,
      required String password,
      required String name,
      String? crm}) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('users/').doc(email).update({
        'name': name,
        'email': email,
        'crm': "$crm",
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  static Future<String?> requestPasswordChangeEmail(
      {required String email}) async {
    try {
      if (await checkEmailRegisterStatus(email: email) == "registred") {
        await _auth.sendPasswordResetEmail(email: email);
        return null;
      }
      return "unregistred";
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  static Future<String?> checkEmailRegisterStatus(
      {required String email}) async {
    dynamic data =
        await FirebaseFirestore.instance.collection('users/').doc(email).get();
    if (!data.exists || data.data()['archived'] == true) {
      return "missing";
    }
    if (data.data()['name'] != null) {
      return "registred";
    }
    return null;
  }

  static Future signOut(
      {required BuildContext context, String endPoint = '/'}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }

      await _auth.signOut();

      await AppController.instance.setUser(null);

      context.vRouter.to('/');
    } catch (e) {
      snackMessage(context, message: 'Tive um erro: ${e.toString()}');
    }
  }

  static Future<void> setUserAndGoToHome(BuildContext context,
      {String endPoint = '/home'}) async {
    await AppController.instance.setUser(FirebaseAuth.instance.currentUser);
    context.vRouter.to(endPoint);

    // Navigator.of(context).popAndPushNamed(endPoint);
  }

  static Future<bool> isLoggedIn() async {
    if (AppController.instance.user == null) {
      await Firebase.initializeApp();

      await for (final u in FirebaseAuth.instance.authStateChanges()) {
        if (u == null) {
          return false;
        } else {
          await AppController.instance.setUser(u);
          break;
        }
      }
    }
    return true;
  }

  // static Future<void> routeGuard(BuildContext context,
  //     {String endPoint = '/home'}) async {
  //   if (AppController.instance.user == null) {
  //     await Firebase.initializeApp();
  //     await for (final u in FirebaseAuth.instance.authStateChanges()) {
  //       if (u == null) {
  //         context.vRouter.to('/');
  //         // Navigator.of(context).popAndPushNamed('/');
  //       } else {
  //         AppController.instance.setUser(u);
  //         context.vRouter.to(endPoint);
  //         // Navigator.of(context).popAndPushNamed(endPoint);
  //       }
  //     }
  //   }
  // }
}
