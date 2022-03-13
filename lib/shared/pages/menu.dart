import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vrouter/vrouter.dart';
import '../../configs/menu_itens.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/authentication.dart';
import '../models/option_menu.dart';
import '../models/profile.dart';
import '../widgets/empty_loading.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final User? _user = AppController.instance.user;

  final Profile? _profile = AppController.instance.profile;

  bool _estaSaindo = false;
  @override
  void initState() {
    super.initState();
  }

  final List<OptionMenu> start = [
    OptionMenu(Icons.home, 'Início', '/home', true, Colors.black)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.topLeft,
          colors: [
            Colors.blueGrey.shade600,
            Colors.blueGrey.shade700,
            Colors.blueGrey.shade900,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5 > 350
                ? 350
                : MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _cabecalhoWidget(),
                const Divider(),
                _menu(),
                ..._botaoSair(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoWidget() {
    if (_user != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipOval(
              child: Material(
                color: Colors.grey,
                child: CachedNetworkImage(
                  fit: BoxFit.fitHeight,
                  imageUrl: _profile!.photoURL,
                  placeholder: (context, url) => loading(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _profile!.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _profile!.role,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      );
      // return ClipOval(
      //   child: Material(
      //     color: Colors.grey.withOpacity(0.3),
      //     child: const Padding(
      //       padding: EdgeInsets.all(16.0),
      //       child: Icon(
      //         Icons.person,
      //         size: 60,
      //         color: Colors.grey,
      //       ),
      //     ),
      //   ),
      // );
    }
    return const Spacer();
  }

  Widget _menu() {
    List<OptionMenu> menu = [
          OptionMenu(Icons.home, 'Início', '/home', true, Colors.black)
        ] +
        getMenu(_profile!.role);

    return Expanded(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: menu.map((value) {
          return value.active
              ? ListTile(
                  leading: Icon(
                    value.icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  title: Text(
                    value.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  onTap: () {
                    context.vRouter.to(value.route);
                    // Navigator.of(context).popAndPushNamed(value.route);
                  },
                )
              : const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  List<Widget> _botaoSair() {
    if (_estaSaindo) {
      return [loading()];
    }
    return [
      ListTile(
        leading: Icon(
          Icons.settings,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          'Perfil',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        onTap: () async {
          setState(() {
            _estaSaindo = true;
          });
          await Authentication.signOut(context: context);
          setState(() {
            _estaSaindo = false;
          });
        },
      ),
      ListTile(
        leading: Icon(
          Icons.logout,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          'Sair',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        onTap: () async {
          setState(() {
            _estaSaindo = true;
          });
          await Authentication.signOut(context: context);
          setState(() {
            _estaSaindo = false;
          });
        },
      ),
    ];
  }
}
