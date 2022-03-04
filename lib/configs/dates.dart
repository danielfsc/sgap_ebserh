import 'package:intl/intl.dart';

String dayFormat = "dd MMM yyyy";
String dayAndHourFormat = "dd MMM yy - HH:mm";

String dayFromTimestamp(date) =>
    DateFormat(dayFormat).format(DateTime.parse(date.toDate().toString()));

String dayAndHourFromTimestamp(date) => DateFormat(dayAndHourFormat)
    .format(DateTime.parse(date.toDate().toString()));
