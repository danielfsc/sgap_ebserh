import 'package:flutter/material.dart';
import 'package:sgap_ebserh/shared/models/option_menu.dart';
import 'package:vrouter/vrouter.dart';

class HomeCardWidget extends StatelessWidget {
  const HomeCardWidget(this.info, {Key? key}) : super(key: key);
  final OptionMenu info;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AbsorbPointer(
        absorbing: !info.active,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            context.vRouter.to(info.route);
            // Navigator.of(context).popAndPushNamed(info.route);
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95 > 450
                ? 450
                : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.width * 0.15 > 250
                ? 250
                : MediaQuery.of(context).size.width * 0.15,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    info.icon,
                    size: 42,
                    color: info.active ? info.color : Colors.grey,
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    info.title,
                    style: TextStyle(
                      color: info.active ? info.color : Colors.grey,
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
