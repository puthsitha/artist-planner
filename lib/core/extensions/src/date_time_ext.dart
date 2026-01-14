import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toMonthYear() {
    return DateFormat('MMMM yyyy').format(this);
  }
}
