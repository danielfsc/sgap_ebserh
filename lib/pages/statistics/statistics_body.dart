import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgap_ebserh/configs/charts.dart';
import 'package:sgap_ebserh/configs/collections.dart';
import 'package:sgap_ebserh/shared/widgets/empty_loading.dart';
import 'package:vrouter/vrouter.dart';

import '../../configs/dates.dart';
import '../../configs/decorations/input_decoration.dart';
import '../../controllers/app_controller.dart';
import '../../shared/widgets/date_form_field.dart';

class StatisticsBody extends StatefulWidget {
  const StatisticsBody({Key? key}) : super(key: key);

  @override
  State<StatisticsBody> createState() => _StatisticsBodyState();
}

class _StatisticsBodyState extends State<StatisticsBody> {
  List<LineChartBarData> chartPoints = [];

  int totalProcedures = 0;
  double totalHours = 0;

  List<String> chartLabel = [];

  double maxY = 0;

  String chartType = 'dayly';

  DateTime initialDate = DateTime(DateTime.now().year);
  DateTime finalDate = DateTime.now();

  List<bool> isSelected = [true, false, false];

  String? userId;

  @override
  Widget build(BuildContext context) {
    userId = context.vRouter.pathParameters['userId'] ??
        AppController.instance.user!.email;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _dateInterval(context),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: StreamBuilder(
                stream: getProcedures(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return loading();
                  } else if (snapshot.data.docs.length == 0) {
                    return const Text(
                        'Nenhum procedimento cadastrado neste período.');
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: makeChart(context, snapshot),
                  );
                },
              ),
            ),
            // _selectPeriod(context),
          ],
        ),
      ),
    );
  }

  Widget _dateInterval(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        SizedBox(
          width: 250,
          child: DateTimeField(
            hideResetIcon: true,
            initialValue: initialDate,
            format: DateFormat(simpleDayFormat),
            decoration: inputDecoration('Início'),
            onChanged: (e) {
              setState(() {
                if (e != null) {
                  initialDate = e;
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
          width: 250,
          child: DateTimeField(
            hideResetIcon: true,
            initialValue: finalDate,
            format: DateFormat(simpleDayFormat),
            decoration: inputDecoration('Fim'),
            onChanged: (e) {
              if (e != null) {
                setState(() {
                  finalDate = e;
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
              if (date != null) {
                finalDate = date;
              }
              return date;
            },
          ),
        ),
      ],
    );
  }

  Widget _typeSelection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: ToggleButtons(
        constraints: const BoxConstraints(maxWidth: 90, maxHeight: 40),
        fillColor: Colors.blue,
        selectedColor: Colors.white,
        children: periodTypes
            .map<Widget>((type) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    type['short']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        onPressed: (int index) {
          setState(() {
            chartType = periodTypes[index]['value']!;
            for (int indexBtn = 0; indexBtn < isSelected.length; indexBtn++) {
              if (indexBtn == index) {
                isSelected[indexBtn] = true;
              } else {
                isSelected[indexBtn] = false;
              }
            }
          });
        },
        isSelected: isSelected,
      ),
    );
  }

  Widget makeChart(context, snapshot) {
    generateData(snapshot);

    return Column(
      children: [
        Wrap(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 40,
          runSpacing: 20,
          runAlignment: WrapAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total: $totalProcedures atos / ${totalHours.toStringAsFixed(1)} horas',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _typeSelection(context),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: LineChart(
              LineChartData(
                maxY: maxY,
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                lineTouchData: lineTouchData(),
                lineBarsData: chartPoints,
                titlesData: titlesData(chartType),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingVerticalLine: (value) => gridLines(),
                  getDrawingHorizontalLine: (value) => gridLines(),
                ),
              ),
              swapAnimationDuration: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }

  FlLine gridLines() {
    return FlLine(
      color: Colors.grey.shade200,
      strokeWidth: 1,
    );
  }

  LineTouchData lineTouchData() => LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              LineBarSpot hours = touchedBarSpots[0];
              LineBarSpot procedure = touchedBarSpots[1];
              return [
                LineTooltipItem(
                  'Data: ${chartLabel[hours.x.toInt()]} \n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: hours.y.toStringAsFixed(1)),
                    const TextSpan(text: ' horas'),
                  ],
                ),
                LineTooltipItem(
                    '',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: procedure.y.toString()),
                      const TextSpan(text: ' atos'),
                    ])
              ];
            }),
        // touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
        //   if (!event.isInterestedForInteractions ||
        //       lineTouch == null ||
        //       lineTouch.lineBarSpots == null) {
        //     setState(() {});
        //     return;
        //   }
        //   final value = lineTouch.lineBarSpots![0].x;

        //   if (value == 0 || value == 6) {
        //     setState(() {
        //       // touchedValue = -1;
        //     });
        //     return;
        //   }

        //   setState(() {
        //     // touchedValue = value;
        //   });
        // }
      );

  FlTitlesData titlesData(String type) => FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          rotateAngle: type == 'weekly'
              ? -60
              : type == 'dayly'
                  ? -30
                  : 0,
          interval: type == 'dayly' ? 7 : 1,
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
          margin: 6,
          getTitles: (double value) {
            if (type != 'monthly') {
              return value + 1 < chartLabel.length
                  ? chartLabel[value.round()]
                  : '';
            }
            return chartLabel[value.round()];
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: (maxY / 5).round() * 1.0,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10),
        ),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
      );

  generateData(snapshot) {
    DateTime startDate = initialDate;

    DateTime endDate = finalDate;

    Map<String, int> sampleSize = {
      'dayly': calculateDaysInterval(startDate, endDate) + 1,
      'weekly': calculateWeeksInterval(startDate, endDate) + 1,
      'monthly': calculateMonthsInterval(startDate, endDate) + 1,
    };

    List<String> labels = [];
    List<double> hours = List.generate(sampleSize[chartType]!, (index) => 0);
    List<int> procedures = List.generate(sampleSize[chartType]!, (index) => 0);

    labels = getLabels(type: chartType, startDate: startDate, size: sampleSize);

    for (DocumentSnapshot doc in snapshot.data.docs) {
      dynamic data = doc.data();
      DateTime date = DateTime.parse(data['date'].toDate().toString());
      int index = getIndex(type: chartType, date: date, startDate: startDate);
      procedures[index]++;
      hours[index] += double.parse(data['duration']) / 60;
    }
    chartLabel = labels;
    totalProcedures = procedures.reduce((value, element) => value + element);
    totalHours = hours.reduce((value, element) => value + element);
    setChartData(procedures, hours);
  }

  int getIndex({
    required String type,
    required DateTime startDate,
    required DateTime date,
  }) {
    switch (type) {
      case 'dayly':
        return dayOfYear(date) - dayOfYear(startDate);
      case 'weekly':
        return weekOfYear(date) - weekOfYear(startDate);
      case 'monthly':
        return date.month - startDate.month;
    }
    return -1;
  }

  List<String> getLabels(
      {required String type, required DateTime startDate, required size}) {
    List<String> output = [];
    switch (type) {
      case 'dayly':
        for (int i = 0; i < size[type]; i++) {
          output.add(DateFormat(chartDayDate)
              .format(startDate.add(Duration(days: i))));
        }
        break;
      case 'weekly':
        for (int i = 0; i < size[type]; i++) {
          output.add(weekInterval(startDate.add(Duration(days: i * 7))));
        }
        break;
      case 'monthly':
        for (int i = 0; i < size[type]; i++) {
          output.add(DateFormat('MMM').format(
              DateTime(startDate.year, startDate.month + i, startDate.day)));
        }
        break;
      default:
    }

    return output;
  }

  void setChartData(procedures, hours) {
    chartPoints = [
      LineChartBarData(
        spots: getPoints(hours),
        isCurved: true,
        barWidth: 2,
        colors: [Colors.blue],
        dotData: FlDotData(show: false),
        preventCurveOverShooting: true,
      ),
      LineChartBarData(
        spots: getPoints(procedures),
        isCurved: true,
        barWidth: 2,
        colors: [Colors.green],
        dotData: FlDotData(show: false),
        preventCurveOverShooting: true,
      ),
    ];
    maxY = getMaxValue(procedures, hours);
  }

  double getMaxValue(List<int> procedures, List<double> hours) {
    return [hours.reduce(max), procedures.reduce(max)].reduce(max) * 1.15;
  }

  List<FlSpot> getPoints(List<dynamic> values) {
    List<FlSpot> out = [];
    for (int i = 0; i < values.length; i++) {
      out.add(FlSpot(i * 1.0, values[i]));
    }
    return out;
  }

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 80,
              colors: [Colors.blue],
            ),
            BarChartRodData(toY: 20, colors: [Colors.red]),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
                toY: 10, colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
                toY: 14, colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
                toY: 15, colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
                toY: 13, colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
                toY: 10, colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
        ),
      ];

  Stream getProcedures() {
    return proceduresCollection(userId!)
        .orderBy('date')
        .where('date', isLessThanOrEqualTo: finalDate)
        .where('date', isGreaterThanOrEqualTo: initialDate)
        .snapshots();
  }
}
