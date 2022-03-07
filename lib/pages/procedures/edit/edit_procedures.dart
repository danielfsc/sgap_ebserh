import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/configs/dates.dart';
import 'package:sgap_ebserh/controllers/app_controller.dart';
import 'package:sgap_ebserh/shared/widgets/multiselect/multiselect_formfield.dart';
import 'package:sgap_ebserh/shared/widgets/snack_message.dart';
import 'package:vrouter/vrouter.dart';

import '../../../configs/decorations/input_decoration.dart';
import '../../../shared/widgets/date_form_field.dart';
import '../../../shared/widgets/empty_loading.dart';

class EditProcedurePage extends StatefulWidget {
  const EditProcedurePage({Key? key}) : super(key: key);

  @override
  State<EditProcedurePage> createState() => _EditProcedurePageState();
}

class _EditProcedurePageState extends State<EditProcedurePage> {
  DateFormat formatDate = DateFormat(dayAndHourFormat);

  Map<String, dynamic> selectedValues = {};

  dynamic oldProcedure;

  dynamic systemDocuments;

  bool isDocumentLoaded = false;

  DateTime? procedureDate;

  String? procedureId;
  String? procedureOwner;

  Widget? fullForm;

  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _controller =
      List.generate(2, (i) => TextEditingController());

  Future? future;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    fullForm = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    procedureId = context.vRouter.pathParameters['document'];
    procedureOwner = context.vRouter.pathParameters['user'] ??
        AppController.instance.user!.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedimento'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9 > 400
                      ? 400
                      : MediaQuery.of(context).size.width * 0.9,
                  child: _selections(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _date(BuildContext context) {
    return DateTimeField(
        format: DateFormat(dayAndHourFormat),
        decoration: inputDecoration('Data do procedimento'),
        controller: _controller[1],
        initialValue: procedureDate,
        validator: (value) {
          if (value == null) {
            return 'A data é obrigatória';
          }
          return null;
        },
        onChanged: (date) {
          procedureDate = date;
        },
        onShowPicker: (context, currentValue) async {
          final date = await showDatePicker(
              context: context,
              firstDate: DateTime(2021),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
          if (date != null) {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            procedureDate = DateTimeField.combine(date, time);
            return DateTimeField.combine(date, time);
          } else {
            return currentValue;
          }
        });
  }

  Widget _duracao(context) {
    return TextField(
      decoration:
          inputDecoration('Duração', suffix: 'min', hintText: 'Em minutos'),
      controller: _controller[0],
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _selections(context) {
    if (isDocumentLoaded) {
      return selectionFields(context);
    }
    return FutureBuilder(
      future: getDocuments(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Erro ao iniciar o Firebase');
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (!isDocumentLoaded) {
            setInitialValues();
          }
          isDocumentLoaded = true;
          return selectionFields(context);
        }
        if (!isDocumentLoaded) {
          return loading();
        }
        return selectionFields(context);
      },
    );
  }

  Future<AsyncSnapshot<dynamic>> getDocuments(BuildContext context) async {
    try {
      await systemCollection
          .orderBy('index')
          .get()
          .then((value) => systemDocuments = value.docs);
      if (procedureId != null) {
        await proceduresCollection(procedureOwner!)
            .doc(procedureId)
            .get()
            .then((value) => oldProcedure = value.data());
      }

      return const AsyncSnapshot.withData(ConnectionState.done, 'ok');
    } catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  void setInitialValues() {
    for (QueryDocumentSnapshot doc in systemDocuments) {
      if (selectedValues[doc.id] == null) {
        selectedValues[doc.id] = [];
      }
    }
    if (procedureId != null) {
      _controller[0].text = oldProcedure['duration'] ?? '';
      procedureDate = DateTime.parse(oldProcedure['date'].toDate().toString());
      _controller[1].text = DateFormat(dayAndHourFormat).format(procedureDate!);
      for (String selection in selectedValues.keys) {
        selectedValues[selection] = oldProcedure[selection] ?? [];
      }
    }
  }

  Widget _spacer() {
    return const SizedBox(height: 10);
  }

  Widget selectionFields(BuildContext context) {
    List<Widget> listSelections = [];

    for (QueryDocumentSnapshot doc in systemDocuments) {
      listSelections.add(multipleSelect(doc));
      listSelections.add(_spacer());
    }
    return Column(
      children: [
        _date(context),
        _spacer(),
        _duracao(context),
        _spacer(),
        ...listSelections,
        _submit(context),
      ],
    );
  }

  void setInitialData() {
    _controller[0].text = oldProcedure['duration'];
    procedureDate = DateTime.parse(oldProcedure['date'].toDate().toString());
    _controller[1].text = DateFormat(dayAndHourFormat).format(procedureDate!);

    for (String selection in selectedValues.keys) {
      selectedValues[selection] = oldProcedure[selection] ?? [];
    }
    isDocumentLoaded = true;
  }

  Widget multipleSelect(doc) {
    Map<String, dynamic> parameter = doc.data();

    String category = doc.id;

    List<dynamic> dataSource = parameter['data'];

    return MultiSelectFormField(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      isMultiSelection: parameter['multiple'],
      autovalidate: AutovalidateMode.onUserInteraction,
      chipBackGroundColor: Colors.blueGrey,
      chipLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      dialogTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      checkBoxActiveColor: Colors.blue,
      checkBoxCheckColor: Colors.white,
      dialogShapeBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      title: Text(
        "${parameter['name']}",
        style: const TextStyle(fontSize: 16),
      ),
      validator: (value) {
        if (value == null || value.length == 0) {
          return 'Selecione ao menos uma opção ${parameter['multiple'] ? "ou mais" : ''}';
        }
        return null;
      },
      dataSource: dataSource,
      textField: 'text',
      valueField: 'symbol',
      okButtonLabel: 'OK',
      cancelButtonLabel: 'Cancelar',
      hintWidget: Text(
          'Selecione ao menos uma opção ${parameter['multiple'] ? "ou mais" : ''}'),
      initialValue: selectedValues[category],
      onSaved: (value) {
        if (value == null) return;
        setState(() {
          selectedValues[category] = value;
        });
      },
    );
  }

  Widget _submit(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _save(context);
          }
        },
        child: const Text('Salvar'));
  }

  Future<void> _save(BuildContext context) async {
    Map<String, dynamic> dataToSave = selectedValues;
    dataToSave['date'] = Timestamp.fromDate(procedureDate!);
    dataToSave['duration'] = _controller[0].text;

    try {
      if (procedureId == null) {
        await proceduresCollection(procedureOwner!).add(dataToSave);
      } else {
        await proceduresCollection(procedureOwner!)
            .doc(procedureId)
            .update(dataToSave);
      }
      context.vRouter.pop();
    } on FirebaseException catch (e) {
      snackMessage(context,
          message: 'Ops, não consegui salvar. Erro: ${e.code}',
          color: Colors.red);
    }
  }
}
