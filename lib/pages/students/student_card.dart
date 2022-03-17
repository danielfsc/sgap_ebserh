import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/configs/cards_menu.dart';
import 'package:vrouter/vrouter.dart';

import '../../shared/widgets/empty_loading.dart';

class StudentCard extends StatelessWidget {
  final Map<String, dynamic> user;
  StudentCard({Key? key, required this.user}) : super(key: key);
  final GlobalKey _menuKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipOval(
                child: Material(
                  color: Colors.grey,
                  child: CachedNetworkImage(
                    fit: BoxFit.fitHeight,
                    imageUrl: user['photoURL'] ?? '',
                    placeholder: (context, url) => loading(),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/nullphoto.png'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['name'].isNotEmpty
                      ? '${user['name']} )'
                      : 'Nome não cadastrado'),
                  Text('E-mail: ${user['email']}'),
                  Text('CRM: ${user['crm']}'),
                  Text(
                      'Admissão: ${DateFormat('d/M/y').format(user['admission'].toDate())}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PopupMenuButton(
                key: _menuKey,
                child: const Icon(
                  Icons.more_vert_outlined,
                  size: 30,
                ),
                itemBuilder: (context) => userCardMenuToPreceptor.map((e) {
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
                    case 'Procedimentos':
                      context.vRouter.to('procedures/${user['email']}');
                      break;

                    case 'Estatística':
                      context.vRouter.to('statistics/${user['email']}');
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
