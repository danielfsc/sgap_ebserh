import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/configs/dates.dart';
import 'package:sgap_ebserh/configs/table_user_column.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class TableDataSource extends DataGridSource {
  final List<DataGridRow> _data = [];
  List<GridColumn> _columns = [];
  TableDataSource(List<Map<String, dynamic>> raw, List<GridColumn> column) {
    _columns = column;
    for (Map<String, dynamic> row in raw) {
      _data.add(DataGridRow(cells: getRowCells(row)));
    }
  }

  List<DataGridCell> getRowCells(Map<String, dynamic> row) {
    List<DataGridCell> out = [];
    for (GridColumn column in _columns) {
      dynamic value = row[column.columnName];
      out.add(
        DataGridCell(
          columnName: column.columnName,
          value: setValue(value, column.columnName),
        ),
      );
    }

    return out;
  }

  String setValue(value, columnName) {
    if (value is Timestamp) {
      return DateFormat(
              columnName == 'admission' ? simpleDayFormat : simpleDayHourFormat)
          .format(dateFromTimestamp(value));
    }
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  @override
  List<DataGridRow> get rows => _data;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final int index = effectiveRows.indexOf(row);
      if (index % 2 != 0) {
        return Colors.blueGrey.shade50;
      }

      return Colors.white;
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((dataGridCell) {
          return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                valueToString(dataGridCell),
              ));
        }).toList());
  }
}

String valueToString(DataGridCell value) {
  if (value.value is Timestamp) {
    return DateFormat(value.columnName == 'adminission'
            ? simpleDayFormat
            : simpleDayHourFormat)
        .format(dateFromTimestamp(value.value));
  }
  return value.value.toString();
}

Widget columnCell(String text) {
  return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ));
}

Future<List<GridColumn>> generateColumns() async {
  List<GridColumn> out = [...userColumn, ...procedureColumn];
  dynamic categories = await systemCollection.orderBy('index').get();
  for (dynamic cat in categories.docs) {
    dynamic data = cat.data();
    out.add(
      GridColumn(
        columnName: cat.id.toString(),
        label: columnCell(data['name']!),
      ),
    );
  }

  return out;
}
