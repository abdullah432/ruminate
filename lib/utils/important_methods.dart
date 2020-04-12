import 'package:intl/intl.dart';

class MyUtils {
  static DateTime now = DateTime.now();
  static String formattedDate = DateFormat('MMM dd, yyyy').format(now);
  
  static getNoteDate(timestamp) {
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = new DateFormat('MMM dd, yyyy');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }
}
