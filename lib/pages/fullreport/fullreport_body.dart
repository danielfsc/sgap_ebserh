import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/controllers/app_controller.dart';
import 'package:sgap_ebserh/controllers/sf_table.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart'
    hide Alignment, Column, Row;

import '../../controllers/helper/save_file_mobile.dart'
    if (dart.library.js) '../../controllers/helper/save_file_web.dart'
    as helper;

import '../../shared/widgets/empty_loading.dart';

import '../../shared/widgets/multiselect/multiselect_formfield.dart';

class FullReportBody extends StatefulWidget {
  const FullReportBody({Key? key}) : super(key: key);

  @override
  State<FullReportBody> createState() => _FullReportBodyState();
}

class _FullReportBodyState extends State<FullReportBody> {
  List<String> students = [];

  List<QueryDocumentSnapshot> studentsData = [];

  List<GridColumn> tableColumns = [];

  List<Map<String, dynamic>> tableRawData = [];

  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _studentsSelection(context),
          // _streamData(context),
          Expanded(child: _streamData(context)),
          _saveButton(context),
        ],
      ),
    );
  }

  Widget _streamData(BuildContext context) {
    return students.isEmpty
        ? const Text('Selecione alguns residentes para gerar o relatório')
        : FutureBuilder(
            future: requestProcedures(context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return _table(context);
              }
              return loading();
            },
          );
  }

  Widget _saveButton(BuildContext context) {
    return students.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Exportar para Excel'),
              onPressed: () async {
                final Workbook workbook =
                    key.currentState!.exportToExcelWorkbook();
                final List<int> bytes = workbook.saveAsStream();
                workbook.dispose();
                await helper.saveAndLaunchFile(
                    bytes, 'relatorio_sgap_${DateTime.now()}.xlsx');
              },
            ),
          )
        : const SizedBox.shrink();
  }

  Future<AsyncSnapshot<dynamic>> requestProcedures(BuildContext context) async {
    print('87: pedindo procedimentos ');
    tableRawData = [];
    for (String student in students) {
      dynamic studentInfo = await usersCollection.doc(student).get();
      QuerySnapshot procedures =
          await proceduresCollection(student).orderBy('date').get();
      print('Definindo table ');
      await setTable(user: studentInfo, procedures: procedures);
    }
    print('Terminei o RequestProcedures');
    return const AsyncSnapshot.withData(ConnectionState.done, 'ok');
  }

  Future<void> setTable(
      {required dynamic user, required QuerySnapshot procedures}) async {
    print('Inicio da definição da tabela');
    Map<String, dynamic> userdata = user.data() as Map<String, dynamic>;

    for (QueryDocumentSnapshot doc in procedures.docs) {
      tableRawData.add({...userdata, ...doc.data() as Map<String, dynamic>});
    }
    print('gerando as colunas');
    tableColumns = await generateColumns();
  }

  Widget _table(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10)),
        child: SfDataGridTheme(
          data: SfDataGridThemeData(headerColor: Colors.blueGrey),
          child: SfDataGrid(
            key: key,
            columns: tableColumns,
            source: TableDataSource(tableRawData, tableColumns),
            frozenColumnsCount: 1,
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            columnWidthMode: ColumnWidthMode.auto,
          ),
        ),
      ),
    );
  }

  Widget _studentsSelection(BuildContext context) {
    print('Montei o select');
    return StreamBuilder(
        stream: getUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return loading();
          } else if (snapshot.data.docs.length == 0) {
            return const Text(
                'Você não possui nenhum estudante para selecionar.');
          }
          return _studentsMultiSelection(context, snapshot);
        });
  }

  Widget _studentsMultiSelection(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> datasource = snapshot.data.docs
        .map((doc) => {'value': doc.id, 'text': doc.data()['name'] ?? doc.id})
        .toList();
    setStudentsData(snapshot.data.docs);
    print('Retornado o select box');
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: MultiSelectFormField(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        autovalidate: AutovalidateMode.onUserInteraction,
        chipBackGroundColor: Colors.blueGrey,
        chipLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        dialogTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        checkBoxActiveColor: Colors.blue,
        checkBoxCheckColor: Colors.white,
        dialogShapeBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        title: const Text(
          "Selecione os residentes",
          style: TextStyle(fontSize: 16),
        ),
        dataSource: datasource,
        textField: 'text',
        valueField: 'value',
        initialValue: students,
        okButtonLabel: 'OK',
        cancelButtonLabel: 'Cancelar',
        hintWidget: const Text('Selecione ao menos uma opção ou mais'),
        onSaved: (value) {
          if (value == null) return;
          setState(() {
            print('Definindo os students');
            students = value.cast<String>();
            print('students definido');
          });
        },
      ),
    );
  }

  void setStudentsData(List<QueryDocumentSnapshot> docs) {
    print('Definindo usuários');
    studentsData = docs;
  }

  Stream getUsers() {
    print('pegando usuários');

    if (AppController.instance.profile!.role == 'preceptor') {
      return usersCollection
          .where('archived', isEqualTo: false)
          .where('preceptors', isEqualTo: AppController.instance.email)
          .snapshots();
    }
    return usersCollection.where('archived', isEqualTo: false).snapshots();
  }
}
