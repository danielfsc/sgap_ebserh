import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String? label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  final List<MultiSelectDialogItem<V>>? items;
  final List<V>? initialSelectedValues;
  final Widget? title;
  final String? okButtonLabel;
  final String? cancelButtonLabel;
  final TextStyle labelStyle;
  final ShapeBorder? dialogShapeBorder;
  final Color? checkBoxCheckColor;
  final Color? checkBoxActiveColor;
  final bool isMultiSelection;

  const MultiSelectDialog({
    Key? key,
    this.items,
    this.initialSelectedValues,
    this.title,
    this.okButtonLabel,
    this.cancelButtonLabel,
    this.labelStyle = const TextStyle(),
    this.dialogShapeBorder,
    this.checkBoxActiveColor,
    this.checkBoxCheckColor,
    this.isMultiSelection = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = <V>[];

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      if (widget.initialSelectedValues!.isNotEmpty) {
        _selectedValues.add(widget.initialSelectedValues![0]);
      }
    }
  }

  void _onItemCheckedChange(V itemValue, bool? checked) {
    setState(() {
      if (widget.isMultiSelection) {
        if (checked!) {
          _selectedValues.add(itemValue);
        } else {
          _selectedValues.remove(itemValue);
        }
      } else {
        if (_selectedValues.contains(itemValue)) {
          _selectedValues.remove(itemValue);
        } else {
          _selectedValues.clear();
          _selectedValues.add(itemValue);
        }
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      shape: widget.dialogShapeBorder,
      contentPadding: const EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items!.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancelButtonLabel!),
          onPressed: _onCancelTap,
        ),
        TextButton(
          child: Text(widget.okButtonLabel!),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      checkColor: widget.checkBoxCheckColor,
      activeColor: widget.checkBoxActiveColor,
      title: Text(
        item.label!,
        style: widget.labelStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}
