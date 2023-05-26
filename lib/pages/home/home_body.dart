import 'package:flutter/material.dart';

import '../../configs/menu_itens.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/authentication.dart';
import '../../shared/models/profile.dart';
import 'home_card.dart';

class HomeBody extends StatelessWidget {
  final Profile _profile = AppController.instance.profile!;
  // List<OptionMenu>? opcoes;
  HomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            ...getMenu(_profile.role).map((value) {
              return HomeCardWidget(value);
            }).toList(),
            logoutCard(context)
          ],
        ),
      ),
    );
  }

  // List<Widget> optionsCards(context) {
  //   if (opcoes == null) {
  //     return [];
  //   }
  //   return opcoes!.map((value) {
  //     return HomeCardWidget(value);
  //   }).toList();
  // }

  Widget logoutCard(context) {
    return Card(
      child: AbsorbPointer(
        absorbing: false,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () async {
            await Authentication.signOut(context: context);
            // Navigator.of(context).popAndPushNamed('/');
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95 > 450
                ? 450
                : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.15 > 250
                ? 250
                : MediaQuery.of(context).size.width * 0.15,
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    size: 42,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
