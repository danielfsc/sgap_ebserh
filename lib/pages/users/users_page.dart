import 'package:flutter/material.dart';
import 'package:sgap_ebserh/shared/pages/page_mask.dart';

import 'users_body.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PageMask(body: UsersBody(), title: 'Usuários');
  }
}
