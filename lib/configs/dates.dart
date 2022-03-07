import 'package:intl/intl.dart';

String dayFormat = "dd MMM yyyy";

String simpleDayFormat = 'dd/MM/yy';

String dayAndHourFormat = "dd MMM yy - HH:mm";

String dayFromTimestamp(date) =>
    DateFormat(dayFormat).format(DateTime.parse(date.toDate().toString()));

String dayAndHourFromTimestamp(date) => DateFormat(dayAndHourFormat)
    .format(DateTime.parse(date.toDate().toString()));

int minYear = 2021;

int maxYear = 2050;
