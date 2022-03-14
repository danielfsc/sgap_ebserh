import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String dayFormat = "dd MMM yyyy";

String chartDayDate = 'dd/MM';

String simpleDayFormat = 'dd/MM/yy';

String dayAndHourFormat = "dd MMM yy - HH:mm";
String simpleDayHourFormat = "dd/MM/yy - HH:mm";

String dayFromTimestamp(date) =>
    DateFormat(dayFormat).format(DateTime.parse(date.toDate().toString()));

String dayAndHourFromTimestamp(date) => DateFormat(dayAndHourFormat)
    .format(DateTime.parse(date.toDate().toString()));

int minYear = 2021;

int maxYear = 2050;

DateTime dateFromTimestamp(Timestamp timestamp) =>
    DateTime.parse(timestamp.toDate().toString());

int dayOfYear(DateTime date) => int.parse(DateFormat("D").format(date));

int weekOfYear(DateTime date) =>
    ((dayOfYear(date) - date.weekday + 10) / 7).floor();

int calculateDaysInterval(DateTime start, DateTime end) =>
    dayOfYear(end) - dayOfYear(start);

int calculateWeeksInterval(DateTime start, DateTime end) =>
    weekOfYear(end) - weekOfYear(start);

int calculateMonthsInterval(DateTime start, DateTime end) =>
    int.parse(DateFormat('MM').format(end)) -
    int.parse(DateFormat('MM').format(start));

DateTime lastDayOfWeek(DateTime date) =>
    date.add(Duration(days: 6 - date.weekday));
DateTime firstDayOfWeek(DateTime date) =>
    date.add(Duration(days: date.weekday - 8));

String weekInterval(DateTime date) =>
    ' ${firstDayOfWeek(date).day}/${firstDayOfWeek(date).month}-${lastDayOfWeek(date).day}/${lastDayOfWeek(date).month}';
