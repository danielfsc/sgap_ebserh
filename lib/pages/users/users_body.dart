import './user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import '../../shared/models/show_user_model.dart';
import '../../shared/widgets/empty_loading.dart';

class UsersBody extends StatefulWidget {
  const UsersBody({Key? key}) : super(key: key);

  @override
  _UsersBodyState createState() => _UsersBodyState();
}

class _UsersBodyState extends State<UsersBody> {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users/');

  String? filterUsers;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getUsers(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return loading();
        } else if (snapshot.data.docs.length == 0) {
          return const Text('Nenhum usuário encontrado.');
        }
        return _usersList(context: context, userList: snapshot.data);
      },
    );
  }

  Widget _usersList({required BuildContext context, userList}) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                TextButton(
                    onPressed: () => setUsers(null),
                    child: const Text('Todos')),
                TextButton(
                    onPressed: () => setUsers('internship'),
                    child: const Text('Graduandos')),
                TextButton(
                    onPressed: () => setUsers('student'),
                    child: const Text('Residentes')),
                TextButton(
                    onPressed: () => setUsers('preceptor'),
                    child: const Text('Preceptores')),
                TextButton(
                    onPressed: () => setUsers('admin'),
                    child: const Text('Administradores')),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: userList.docs.map<Widget>((doc) {
                ShowUserModel user = ShowUserModel.fromDoc(doc);
                return UserCard(user: user);
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () {
                    context.vRouter.to('newuser');
                  },
                  child: const Text('Adicionar novo usuário')),
            ),
          ],
        ),
      ),
    );
  }

  void setUsers(String? filter) {
    setState(() {
      filterUsers = filter;
      // getUsers();
    });
  }

  Stream<QuerySnapshot<Object?>> getUsers() {
    if (filterUsers == null) {
      return usersCollection.where('archived', isEqualTo: false).snapshots();
    }
    return usersCollection
        .where('archived', isEqualTo: false)
        .where('role', isEqualTo: filterUsers)
        .snapshots();
  }
}
