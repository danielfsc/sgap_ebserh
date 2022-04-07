import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../configs/collections.dart';
import '../../../configs/widths.dart';
import '../../../shared/widgets/empty_loading.dart';
import '../../../shared/widgets/show_alert.dart';
import '../../../shared/widgets/snack_message.dart';

class EditCategoriesPage extends StatefulWidget {
  const EditCategoriesPage({Key? key}) : super(key: key);

  @override
  State<EditCategoriesPage> createState() => _EditCategoriesPageState();
}

class _EditCategoriesPageState extends State<EditCategoriesPage> {
  List<dynamic> categories = [];

  final TextEditingController _nameField = TextEditingController();
  final TextEditingController _documentName = TextEditingController();

  @override
  void dispose() {
    _nameField.dispose();
    _documentName.dispose();
    super.dispose();
  }

  bool isMultiple = false;
  bool isEnabledDocumentName = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar campos')),
      body: Center(
        child: SizedBox(
          width: defaultCardWidth(context),
          child: Column(
            children: [
              _newCategory(context),
              _listSystemCategories(context),
            ],
          ),
        ),
      ),
    );
  }

  _newCategory(context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
          onPressed: () {
            _editDialog(context: context);
          },
          child: const Text('Novo Campo')),
    );
  }

  void _editDialog({required BuildContext context, dynamic document}) async {
    _nameField.text = '';
    _documentName.text = '';

    isEnabledDocumentName = true;

    if (document != null) {
      _nameField.text = document.data()['name'];
      _documentName.text = document.id;
      isMultiple = document.data()['multiple'];
      isEnabledDocumentName = false;
    }
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adicione um campo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {},
                    controller: _nameField,
                    decoration:
                        const InputDecoration(hintText: "Nome do campo"),
                  ),
                  TextField(
                    onChanged: (value) {},
                    controller: _documentName,
                    enabled: isEnabledDocumentName,
                    decoration: const InputDecoration(
                        hintText: "Uma palavra para o campo"),
                  ),
                  Row(
                    children: [
                      const Text('Permitir múltiplas seleções? '),
                      Checkbox(
                        checkColor: Colors.white,
                        value: isMultiple,
                        onChanged: (bool? value) {
                          setState(() {
                            isMultiple = value!;
                          });
                        },
                      ),
                    ],
                  )
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
                      name: _nameField.text,
                      id: _documentName.text,
                      multiple: isMultiple,
                      document: document,
                    );
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          });
        });
  }

  saveValue(
      {required String name,
      required String id,
      required bool multiple,
      dynamic document}) {
    if (document == null) {
      systemCollection.doc(id).set({
        'name': name,
        'multiple': multiple,
        'data': [],
        'index': categories.length
      });
    } else {
      systemCollection
          .doc(document.id)
          .update({'name': name, 'multiple': multiple});
    }
  }

  Widget _listSystemCategories(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: systemCollection.orderBy('index').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return const Text('Erro ao comunicar-se com o firebase');
          }
          if (snapshot.hasData) {
            return _categoriesList(context, snapshot.data.docs);
          }
          return loading();
        },
      ),
    );
  }

  Widget _categoriesList(context, docs) {
    categories = docs;
    return ReorderableListView(
      children: categories.map<Widget>((doc) {
        return categoryCard(context, doc);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        dynamic document = categories.removeAt(oldIndex);
        categories.insert(
            newIndex > oldIndex ? newIndex - 1 : newIndex, document);

        categories.asMap().forEach((index, d) {
          systemCollection.doc(d.id).update({'index': index});
        });
        setState(() {});
      },
    );
  }

  Widget categoryCard(context, document) {
    return Card(
      key: ValueKey(document),
      child: ListTile(
        title: Text(document.data()['name']),
        subtitle: Text(document.id),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editDialog(context: context, document: document);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  if (await showAlert(context,
                      title: 'Deletar Campo',
                      message:
                          "ATENÇÃO: Você vai deletar um campo relacionado a procedimentos.\n \nEsta ação é irreversível e limpar todos os dados relacionados a esse campo!\nTem certeza?",
                      cancelTitle: 'CANCELAR',
                      confirmTitle: 'Ok')) {
                    try {
                      systemCollection.doc(document.id).delete();
                      snackMessage(context,
                          message: 'Campo deletado com suscesso',
                          color: Colors.orange);
                    } on FirebaseException catch (e) {
                      snackMessage(context,
                          message: 'Tive um problema. Código: ${e.code}',
                          color: Colors.red);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
