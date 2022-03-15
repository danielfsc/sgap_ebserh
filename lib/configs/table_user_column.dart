import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../controllers/sf_table.dart';

List<GridColumn> userColumn = [
  GridColumn(
    columnName: 'name',
    width: 150,
    label: columnCell('nome'),
  ),
  GridColumn(
    columnName: 'crm',
    // width: 100,
    label: columnCell('CRM'),
  ),
  GridColumn(
    columnName: 'admission',
    label: columnCell('Admissão'),
  ),
  GridColumn(
    columnName: 'email',
    visible: false,
    label: columnCell('E-mail'),
  ),
  GridColumn(
    columnName: 'preceptors',
    visible: false,
    label: columnCell('Preceptor'),
  ),
  GridColumn(
    columnName: 'photoURL',
    visible: false,
    label: columnCell('URL foto'),
  ),
  GridColumn(
    columnName: 'role',
    visible: false,
    label: columnCell('papel'),
  ),
  GridColumn(
    columnName: 'archived',
    visible: false,
    label: columnCell('Arquivado'),
  ),
];
List<GridColumn> procedureColumn = [
  GridColumn(
    columnName: 'date',
    label: columnCell('Data'),
  ),
  GridColumn(
    columnName: 'duration',
    label: columnCell('Duração'),
  )
];
