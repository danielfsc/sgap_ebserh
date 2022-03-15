// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../configs/dates.dart';
import '../../configs/decorations/input_decoration.dart';
import 'date_form_field.dart';

class DateInterval extends StatefulWidget {
  DateTime start;
  DateTime end;
  String startText;
  String endText;
  void Function(List<DateTime>)? onChange;
  bool hideResetIcon;
  String textFormat;
  double width;
  DateInterval({
    Key? key,
    required this.start,
    required this.end,
    this.startText = 'Início',
    this.endText = 'Fim',
    this.textFormat = "dd/MM/yy",
    this.hideResetIcon = false,
    this.width = 250,
    this.onChange,
  }) : super(key: key);

  @override
  State<DateInterval> createState() => _DateIntervalState();
}

class _DateIntervalState extends State<DateInterval> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          SizedBox(
            width: widget.width,
            child: DateTimeField(
              hideResetIcon: widget.hideResetIcon,
              initialValue: widget.start,
              format: DateFormat(widget.textFormat),
              decoration: inputDecoration(widget.startText),
              onChanged: (e) {
                setState(() {
                  if (e != null) {
                    widget.start = e;
                    if (widget.onChange != null) {
                      widget.onChange!([widget.start, widget.end]);
                    }
                  }
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
            width: widget.width,
            child: DateTimeField(
              hideResetIcon: widget.hideResetIcon,
              initialValue: widget.end,
              format: DateFormat(widget.textFormat),
              decoration: inputDecoration('Fim'),
              onChanged: (e) {
                if (e != null) {
                  setState(() {
                    widget.end = e;
                    if (widget.onChange != null) {
                      widget.onChange!([widget.start, widget.end]);
                    }
                  });
                }
              },
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(minYear),
                  initialDate: (currentValue ?? DateTime.now()),
                  lastDate: DateTime(maxYear),
                );
                // if (date != null) {
                //   widget.end = date;
                // }
                return date;
              },
            ),
          ),
        ],
      ),
    );
  }
}
