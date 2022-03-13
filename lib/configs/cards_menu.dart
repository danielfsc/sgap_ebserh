import 'package:flutter/material.dart';

import '../shared/models/icon_menu.dart';

var userCardMenu = [
  IconMenu('Procedimentos', Icons.receipt_long),
  IconMenu('Estatística', Icons.insights),
  // IconMenu('Relatório', Icons.manage_search),
  IconMenu('Editar', Icons.edit, isPublic: false),
  IconMenu('Arquivar', Icons.archive, isPublic: false),
  // IconMenu('Deletar', Icons.delete, isPublic: false),
];

List<IconMenu> procedureCardMenu = [
  // IconMenu('Visualizar', Icons.visibility),
  IconMenu(
    'Editar',
    Icons.edit,
  ),
  IconMenu(
    'Deletar',
    Icons.delete,
  ),
];
