import 'package:flutter/material.dart';

import '../shared/models/option_menu.dart';

List<OptionMenu> userMenu = [
  OptionMenu(Icons.data_saver_on, 'Novo procedimento', '/procedures/new', true,
      Colors.blueAccent),
  OptionMenu(
      Icons.receipt_long, 'Procedimentos', '/procedures', true, Colors.red),
  OptionMenu(Icons.insights, 'Estatística', '/statistics', true, Colors.green),
];

List<OptionMenu> preceptorMenu = [
  OptionMenu(
      Icons.school, 'Meus Estudantes', '/students', false, Colors.blueAccent),
  OptionMenu(
      Icons.table_chart, 'Relatórios', '/fullreport', true, Colors.orange),
];

List<OptionMenu> adminMenu = [
  OptionMenu(Icons.people, 'Usuários', '/users', true, Colors.red),
  OptionMenu(Icons.settings_applications, 'Sistema', '/system', true,
      Colors.blueAccent),
];

List<OptionMenu> getMenu(String role) {
  List<OptionMenu> out = userMenu;
  out += role == "preceptor" ? preceptorMenu : [];
  out += role == "admin" ? [...preceptorMenu, ...adminMenu] : [];
  return out;
}
