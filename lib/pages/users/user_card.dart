import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/configs/user_card_menu.dart';
import 'package:sgap_ebserh/shared/models/show_user_model.dart';
import 'package:sgap_ebserh/shared/widgets/snack_message.dart';
import 'package:vrouter/vrouter.dart';

import '../../configs/vars.dart';
import '../../shared/widgets/empty_loading.dart';
import '../../shared/widgets/show_alert.dart';

class UserCard extends StatefulWidget {
  final ShowUserModel user;
  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final GlobalKey _menuKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final ShowUserModel user = widget.user;
    return Card(
        elevation: 8,
        shadowColor: Colors.blueGrey,
        margin: const EdgeInsets.all(10),
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 1)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95 > 400
              ? 400
              : MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.width * 0.10 > 250
              ? 250
              : MediaQuery.of(context).size.width * 0.10,
          child: Row(
            children: [
              _userPhoto(user.photoURL),
              Expanded(child: _userInfo(user)),
              _userActions(context, user),
            ],
          ),
        ));
  }

  Widget _userActions(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PopupMenuButton(
        key: _menuKey,
        child: const Icon(
          Icons.more_vert_outlined,
          size: 30,
        ),
        itemBuilder: (context) => userCardMenu.map((e) {
          return PopupMenuItem(
            value: e.value,
            child: ListTile(
              leading: Icon(e.icon),
              title: Text(e.value),
            ),
          );
        }).toList(),
        onSelected: (value) async {
          switch (value) {
            case 'Editar':
              context.vRouter.to('edituser/${user.email}');
              break;

            case 'Relatório':
              break;

            case 'Visualizar':
              break;

            case 'Arquivar':
              _archiveUser(context, user.email);
              break;
            // case 'Deletar':
            //   _deleteUser(context, user.email);
            //   break;
          }
        },
      ),
    );
  }

  Future<void> _archiveUser(BuildContext context, String email) async {
    if (await showAlert(context,
        title: 'ARQUIVAR USUÁRIO',
        message:
            "ATENÇÃO: Você vai arquivar este USUÁRIO e TODOS os registros relativo a esse usuário.\nVocê só poderar os dados acessando diretamente o banco de dados.\nTem certeza?",
        cancelTitle: 'CANCELAR',
        confirmTitle: 'Arquivar')) {
      try {
        await FirebaseFirestore.instance
            .collection('users/')
            .doc(email)
            .update({'archived': true});
        snackMessage(
          context,
          message: 'Usuário $email arquivado com sucesso.',
          color: Colors.orange,
        );
      } on FirebaseException catch (e) {
        snackMessage(
          context,
          message: 'Ops, não consegui deletar: ${e.code}',
          color: Colors.red,
        );
      }
    }
  }

  Future<void> _deleteUser(BuildContext context, String email) async {
    if (await showAlert(context,
        title: 'DELETAR USUÁRIO',
        message:
            "ATENÇÃO: Você vai deletar este USUÁRIO e TODOS os registros relativo a esse usuário.\nVOCÊ TEM ABSOLUTA CERTEZA?",
        cancelTitle: 'CANCELAR',
        confirmTitle: 'deletar')) {
      try {
        FirebaseFirestore.instance.collection('users/').doc(email).delete();
        snackMessage(
          context,
          message: 'Usuário $email deletado com sucesso.',
          color: Colors.orange,
        );
      } on FirebaseException catch (e) {
        snackMessage(
          context,
          message: 'Ops, não consegui deletar: ${e.code}',
          color: Colors.red,
        );
      }
    }
  }

  Widget _userInfo(ShowUserModel user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.name.isNotEmpty
            ? '${user.name}  - (${rolesValues[user.role]})'
            : 'Nome não cadastrado - (${rolesValues[user.role]})'),
        Text('E-mail: ${user.email}'),
        Text('CRM: ${user.crm}'),
        Text(
            'Admissão: ${DateFormat('d/M/y').format(user.admission.toDate())}'),
        hasPreceptor(user)
            ? Text('Preceptor: ${user.preceptor}')
            : const SizedBox.shrink(),
      ],
    );
  }

  bool hasPreceptor(ShowUserModel user) {
    return user.preceptor != null && user.preceptor!.isNotEmpty;
  }

  Widget _userPhoto(String photoURL) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipOval(
        child: Material(
          color: Colors.grey,
          child: CachedNetworkImage(
            fit: BoxFit.fitHeight,
            imageUrl: photoURL.isEmpty ? nullPhotoURL : photoURL,
            placeholder: (context, url) => loading(),
            errorWidget: (context, url, error) =>
                Image.asset('assets/nullphoto.png'),
          ),
        ),
      ),
    );
  }
}
