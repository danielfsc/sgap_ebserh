import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgap_ebserh/configs/cards_menu.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/configs/dates.dart';
import 'package:sgap_ebserh/controllers/app_controller.dart';
import 'package:sgap_ebserh/shared/pages/page_mask.dart';
import 'package:sgap_ebserh/shared/widgets/empty_loading.dart';
import 'package:sgap_ebserh/shared/widgets/show_alert.dart';
import 'package:sgap_ebserh/shared/widgets/snack_message.dart';
import 'package:vrouter/vrouter.dart';

class ProcedurePage extends StatefulWidget {
  const ProcedurePage({Key? key}) : super(key: key);

  @override
  State<ProcedurePage> createState() => _ProcedurePageState();
}

class _ProcedurePageState extends State<ProcedurePage> {
  String? userId;

  int? expandedValue;

  @override
  Widget build(BuildContext context) {
    userId = context.vRouter.pathParameters['userId'] ??
        AppController.instance.user!.email;
    return PageMask(
      title: 'Procedimentos',
      body: StreamBuilder(
          stream: proceduresCollection(userId!).orderBy('date').snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return loading();
            } else if (snapshot.data.docs.length == 0) {
              return const Text('Nenhum procedimento cadastrado');
            }
            return listProcedures(context, snapshot);
          }),
    );
  }

  Widget listProcedures(BuildContext context, AsyncSnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.docs.length,
      itemBuilder: (BuildContext context, index) {
        dynamic procedure = snapshot.data.docs[index];
        return Card(
          child: ListTile(
            title: Text(dayAndHourFromTimestamp(procedure['date'])),
            subtitle: Text('${procedure['duration']} min'),
            trailing: _procedureActions(context, procedure),
          ),
        );
      },
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
            print('Deletar');
            break;

          case 'Visualizar':
            print('Visualizar');
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
