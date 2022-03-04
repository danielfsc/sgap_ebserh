import 'package:flutter/material.dart';
import 'package:sgap_ebserh/controllers/authentication.dart';
import 'package:sgap_ebserh/pages/procedures/edit/edit_procedures.dart';
import 'package:sgap_ebserh/pages/procedures/procedures_page.dart';
import 'package:vrouter/vrouter.dart';

import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/signup/signup_page.dart';
import '../pages/system/system_page.dart';
import '../pages/users/edituser/edit_user_page.dart';
import '../pages/users/users_page.dart';

List<VRouteElement> vRoutes = [
  VWidget(
    path: '/',
    widget: const LoginPage(),
    stackedRoutes: [
      VWidget(path: '/signup', widget: const SignUpPage()),
    ],
  ),
  VGuard(
    beforeEnter: (vRedirector) async => isLoggedIn(vRedirector),
    stackedRoutes: [
      VWidget(path: '/home', widget: const HomePage()),
      VWidget(path: '/system', widget: const SystemPage()),
      VWidget(
        path: '/procedures',
        widget: const ProcedurePage(),
        stackedRoutes: [
          VWidget(path: 'new', widget: const EditProcedurePage()),
          VWidget(path: 'edit/:document', widget: const EditProcedurePage()),
          VWidget(path: 'edit/:document/', widget: const EditProcedurePage()),
        ],
      ),
      VWidget(
        path: '/procedures/:user',
        widget: const ProcedurePage(),
        stackedRoutes: [
          VWidget(path: 'edit/:document', widget: const EditProcedurePage()),
        ],
      ),
      VWidget(
        path: '/users',
        widget: const UsersPage(),
        stackedRoutes: [
          VWidget(path: 'newuser', widget: const EditUser()),
          VWidget(path: 'edituser/:email', widget: const EditUser()),
        ],
      ),
    ],
  ),
];

Future<void> isLoggedIn(VRedirector redirector) async {
  if (await Authentication.isLoggedIn()) {
    return;
  }
  redirector.to('/');
}

var routes = <String, WidgetBuilder>{
  '/': (context) => const LoginPage(),
  '/signUp': (context) => const SignUpPage(),
  '/home': (context) => const HomePage(),
  '/system': (context) => const SystemPage(),
  '/users': (context) => const UsersPage(),
};
