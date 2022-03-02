import 'package:flutter/material.dart';
import 'package:sgap_ebserh/shared/models/option_menu.dart';

List<OptionMenu> userMenu = [
  OptionMenu(Icons.data_saver_on, 'Novo procedimento', '/newprocedure', true,
      Colors.blueAccent),
  OptionMenu(
      Icons.receipt_long, 'Procedimentos', '/procedures', true, Colors.red),
  OptionMenu(Icons.insights, 'Estatística', '/history', false, Colors.orange),
];

List<OptionMenu> preceptorMenu = [
  OptionMenu(
      Icons.school, 'Meus Estudantes', '/students', true, Colors.blueAccent),
  OptionMenu(
      Icons.manage_search, 'Relatórios', '/reports', true, Colors.orange),
];

List<OptionMenu> adminMenu = [
  OptionMenu(Icons.people, 'Usuários', '/users', true, Colors.red),
  OptionMenu(Icons.settings_applications, 'Sistema', '/system', true,
      Colors.blueAccent),
];

List<OptionMenu> getMenu(String role) {
  List<OptionMenu> out = role == "student" ? userMenu : preceptorMenu;
  out += role == "admin" ? adminMenu : [];
  return out;
}
