import 'package:flutter/material.dart';

import '../shared/models/icon_menu.dart';

var userCardMenu = [
  IconMenu('Visualizar', Icons.visibility),
  IconMenu('Relatório', Icons.manage_search),
  IconMenu('Editar', Icons.edit, isPublic: false),
  IconMenu('Arquivar', Icons.archive, isPublic: false),
  // IconMenu('Deletar', Icons.delete, isPublic: false),
];
