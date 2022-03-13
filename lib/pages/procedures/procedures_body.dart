import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vrouter/vrouter.dart';

import '../../configs/cards_menu.dart';
import '../../configs/collections.dart';
import '../../configs/dates.dart';
import '../../configs/decorations/input_decoration.dart';
import '../../configs/widths.dart';
import '../../controllers/app_controller.dart';
import '../../shared/widgets/date_form_field.dart';
import '../../shared/widgets/empty_loading.dart';
import '../../shared/widgets/show_alert.dart';
import '../../shared/widgets/snack_message.dart';
import '../../shared/widgets/super_tooltip.dart';

class ProceduresBody extends StatefulWidget {
  const ProceduresBody({Key? key}) : super(key: key);

  @override
  State<ProceduresBody> createState() => _ProceduresBodyState();
}

class _ProceduresBodyState extends State<ProceduresBody> {
  String? userId;

  DateTime? startDate;
  DateTime? endDate;

  bool isOwner = true;

  @override
  Widget build(BuildContext context) {
    if (context.vRouter.pathParameters['userId'] != null) {
      isOwner = false;
    }
    userId = context.vRouter.pathParameters['userId'] ??
        AppController.instance.user!.email;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          _dateInterval(context),
          const SizedBox(height: 30),
          StreamBuilder(
              stream: proceduresCollection(userId!)
                  .orderBy('date')
                  .where('date',
                      isLessThanOrEqualTo: endDate ?? DateTime(maxYear))
                  .where('date',
                      isGreaterThanOrEqualTo: startDate ?? DateTime(minYear))
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return loading();
                } else if (snapshot.data.docs.length == 0) {
                  return const Text('Nenhum procedimento cadastrado');
                }
                return listProcedures(context, snapshot);
              }),
          const SizedBox(height: 30),
          isOwner
              ? ElevatedButton(
                  onPressed: () => context.vRouter.to('new'),
                  child: const Text('Novo Procedimento'))
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _dateInterval(context) {
    return Wrap(
      spacing: 20,
      children: [
        SizedBox(
          width: 250,
          child: DateTimeField(
            format: DateFormat(simpleDayFormat),
            decoration: inputDecoration('Início'),
            onChanged: (e) {
              setState(() {
                startDate = e;
              });
            },
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(minYear),
                initialDate: (currentValue ?? DateTime.now()),
                lastDate: DateTime(maxYear),
              );
              return date;
            },
          ),
        ),
        SizedBox(
          width: 250,
          child: DateTimeField(
            format: DateFormat(simpleDayFormat),
            decoration: inputDecoration('Fim'),
            onChanged: (e) {
              setState(() {
                endDate = e;
              });
            },
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime(minYear),
                initialDate: (currentValue ?? DateTime.now()),
                lastDate: DateTime(maxYear),
              );
              if (date != null) {
                endDate = date;
              }
              return date;
            },
          ),
        ),
      ],
    );
  }

  Widget listProcedures(BuildContext context, AsyncSnapshot snapshot) {
    return Wrap(
      spacing: 20,
      children: snapshot.data.docs
          .map<Widget>((doc) => procedureCard(context, doc))
          .toList(),
    );
  }

  Widget procedureCard(context, procedure) {
    return SizedBox(
      width: defaultCardWidth(context),
      child: Card(
        child: ListTile(
          leading: tooltip(context, procedure),
          title: Text(dayAndHourFromTimestamp(procedure['date'])),
          subtitle: Text('${procedure['duration']} min'),
          trailing: isOwner ? _procedureActions(context, procedure) : null,
        ),
      ),
    );
  }

  Widget tooltip(context, procedure) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          child: const Icon(Icons.search),
          onTap: () {
            SuperTooltip tooltip = SuperTooltip(
              maxWidth: 350,
              popupDirection: TooltipDirection.down,
              showCloseButton: ShowCloseButton.inside,
              content: Material(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FutureBuilder(
                  future: systemCollection.orderBy('index').get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Erro ao iniciar o Firebase');
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return tooltipBody(context, procedure, snapshot);
                    }

                    return loading();
                  },
                ),
              )),
            );

            tooltip.show(context);
          },
        );
      },
    );
  }

  tooltipBody(BuildContext context, dynamic procedure, AsyncSnapshot snapshot) {
    return SingleChildScrollView(
      child: Column(
        children: snapshot.data.docs
            .map<Widget>((e) => boldTitleText(
                title: e.data()['name'], text: getFieldText(e, procedure)))
            .toList(),
      ),
    );
  }

  String getFieldText(field, procedure) {
    String parameter = field.id;
    List<dynamic> parameterOptions = field.data()['data'] ?? [];
    List<dynamic> rawValues = procedure.data()[parameter] ?? [];
    String out = '';
    for (String rv in rawValues) {
      dynamic gp = parameterOptions
          .where((element) => element['symbol'] == rv)
          .map<String>(
            (e) => e['text'],
          )
          .toString();

      out += gp.toString();
    }

    return out.replaceAll(')(', '; ').replaceAll('(', '').replaceAll(')', '');
  }

  Widget boldTitleText({required String title, required String text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              text,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _procedureActions(BuildContext context, procedure) {
    return PopupMenuButton(
      child: const Icon(
        Icons.more_vert_outlined,
        size: 30,
      ),
      itemBuilder: (context) => procedureCardMenu.map((e) {
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
            if (context.vRouter.pathParameters['userId'] == null) {
              context.vRouter.to('edit/${procedure.id}');
            } else {
              context.vRouter.to('edit/$userId/${procedure.id}');
            }
            break;

          case 'Deletar':
            _deleteProcedure(context, procedure.id);
            break;
        }
      },
    );
  }

  Future<void> _deleteProcedure(BuildContext context, String docId) async {
    if (await showAlert(context,
        title: 'Deletar Procedimento',
        message:
            "ATENÇÃO: Você vai deletar este procedimento e esta ação é irreversível.\nTem certeza?",
        cancelTitle: 'CANCELAR',
        confirmTitle: 'Ok')) {
      try {
        proceduresCollection(userId!).doc(docId).delete();
        snackMessage(context,
            message: 'Procedimento deletado com sucesso.',
            color: Colors.orange);
      } on FirebaseException catch (e) {
        snackMessage(context,
            message: 'Não consegui remover o procedimento. Erro: ${e.code}',
            color: Colors.red);
      }
    }
  }
}
