import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: "en_US",
      symbol: "\$",
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat("MMM dd, yyyy");
    return formatter.format(date);
  }

  static String formatDateTime(DateTime date) {
    final formatter = DateFormat("MMM dd, yyyy • HH:mm");
    return formatter.format(date);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
