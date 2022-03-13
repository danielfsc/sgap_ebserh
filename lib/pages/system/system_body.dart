import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import '../../shared/models/system_option.dart';
import '../../shared/widgets/empty_loading.dart';
import '../../shared/widgets/show_alert.dart';

class SystemBody extends StatefulWidget {
  const SystemBody({Key? key}) : super(key: key);

  @override
  _SystemBodyState createState() => _SystemBodyState();
}

class _SystemBodyState extends State<SystemBody> {
  String? selectedSystem;

  List<dynamic> systemData = [];

  CollectionReference systemCollection =
      FirebaseFirestore.instance.collection('system');

  final TextEditingController _textField = TextEditingController();
  final TextEditingController _symbolField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {
              context.vRouter.to('editcategories');
            },
            child: const Text('Modificar os campos'),
          ),
          const SizedBox(height: 30),
          _systemSelectionWidget(),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: _addButton(context),
          ),
          Expanded(child: _buildSelectedSystem(context)),
        ],
      ),
    );
  }

  Widget _buildSelectedSystem(BuildContext context) {
    return selectedSystem == null
        ? const Text('Nenhuma categoria selecionada')
        : FutureBuilder(
            future: systemCollection.doc(selectedSystem).get(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Text('deu merda');
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.data()['data'].length == 0) {
                  return const SizedBox.shrink();
                }
                SystemOption system =
                    SystemOption.fromMap(snapshot.data.data());

                return _showReordableData(context, system);
              }
              return loading();
            });
  }

  Widget _showReordableData(BuildContext context, SystemOption system) {
    systemData = system.data;
    return SizedBox(
      width: 350,
      child: ReorderableListView(
          children: systemData.map<Widget>((data) {
            int index = systemData.indexOf(data);
            return Card(
              key: ValueKey(data),
              child: ListTile(
                title: Text(
                  data['text'],
                  softWrap: true,
                ),
                subtitle: Text(data['symbol']),
                onLongPress: () {
                  deleteData(context: context, system: system, index: index);
                },
                trailing: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                  child: IconButton(
                      onPressed: () {
                        editDialog(
                            context: context, system: system, index: index);
                      },
                      icon: const Icon(Icons.edit)),
                ),
              ),
            );
          }).toList(),
          onReorder: (oldIndex, newIndex) {
            dynamic document = systemData.removeAt(oldIndex);
            systemData.insert(
                newIndex > oldIndex ? newIndex - 1 : newIndex, document);
            systemCollection.doc(selectedSystem).update({'data': systemData});

            setState(() {});
          }),
    );
  }

  // Widget _showData(BuildContext context, SystemOption system) {
  //   return Expanded(
  //     child: SizedBox(
  //       width: 350,
  //       child: ListView.builder(
  //           itemCount: system.data.length,
  //           itemBuilder: (context, index) {
  //             dynamic value = system.data[index];
  //             return SizedBox(
  //               width: 350,
  //               child: Card(
  //                 child: ListTile(
  //                   title: Text(value['text']),
  //                   subtitle: Text(value['symbol']),
  //                   onLongPress: () {
  //                     deleteData(
  //                         context: context, system: system, index: index);
  //                   },
  //                   trailing: IconButton(
  //                       onPressed: () {
  //                         editDialog(
  //                             context: context, system: system, index: index);
  //                       },
  //                       icon: const Icon(Icons.edit)),
  //                 ),
  //               ),
  //             );
  //           }),
  //     ),
  //   );
  // }

  Future<void> deleteData(
      {required BuildContext context,
      required SystemOption system,
      required int index}) async {
    if (await showAlert(context,
        title: 'Deletar Item',
        message:
            "Essa ação não pode ser desfeita.\nTem certeza que quer continuar?",
        cancelTitle: 'Cancelar')) {
      system.deleteData(index);
      system.save(selectedSystem!);
      setState(() {});
    }
  }

  Widget _addButton(
    BuildContext context,
  ) {
    return selectedSystem == null
        ? const SizedBox.shrink()
        : FutureBuilder(
            future: systemCollection.doc(selectedSystem).get(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasError) {
                return const Text('deu merda');
              } else if (snapshot.connectionState == ConnectionState.done) {
                SystemOption system =
                    SystemOption.fromMap(snapshot.data.data());

                return ElevatedButton(
                  onPressed: () {
                    editDialog(context: context, system: system);
                  },
                  child: Text('Adicionar ${system.name}'),
                );
              }
              return loading();
            });
  }

  void editDialog(
      {required BuildContext context,
      required SystemOption system,
      int? index}) {
    if (index != null) {
      _textField.text = system.data[index]['text'];
      _symbolField.text = system.data[index]['symbol'];
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adicione um ${system.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {},
                  controller: _textField,
                  decoration:
                      InputDecoration(hintText: "Texto do ${system.name}"),
                ),
                TextField(
                  onChanged: (value) {},
                  controller: _symbolField,
                  decoration:
                      const InputDecoration(hintText: "Símbolo na tabela"),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              ElevatedButton(
                child: const Text('Salvar'),
                onPressed: () {
                  saveValue(
                    system: system,
                    text: _textField.text,
                    symbol: _symbolField.text,
                    index: index,
                  );
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  saveValue(
      {required SystemOption system,
      required String text,
      required String symbol,
      int? index}) {
    system.updateData(text: text, symbol: symbol, index: index);

    system.save(selectedSystem!);
    _textField.text = '';
    _symbolField.text = '';
  }

  Widget _systemSelectionWidget() {
    return StreamBuilder(
      stream: systemCollection.orderBy('index').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return loading();
        } else if (snapshot.data.docs.length == 0) {
          return const Text(
              'O sistema está em branco, deu algum problema grave.');
        }
        return _selectDropMenu(context, snapshot.data.docs);
      },
    );
  }

  Widget _selectDropMenu(BuildContext context, List<DocumentSnapshot> data) {
    return DropdownButton<String?>(
      value: selectedSystem,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      // style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.blueGrey,
      ),
      onChanged: (String? newValue) {
        setNewSystemSelection(newValue);
      },
      items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text("Escolha o campo"),
            )
          ] +
          data.map<DropdownMenuItem<String?>>((value) {
            return dropMenuItem(value);
          }).toList(),
    );
  }

  setNewSystemSelection(String? selected) {
    setState(() {
      selectedSystem = selected;
    });
  }

  Future<QuerySnapshot> requestAllSystemDocs() async {
    return await systemCollection.orderBy('index').get();
  }

  dropMenuItem(value) {
    return DropdownMenuItem<String>(
      value: value.reference.id,
      child: Text(value.data()['name']),
    );
  }
}
