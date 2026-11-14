import 'package:flutter/foundation.dart';


class Lang {
  static final ValueNotifier<bool> isArabic = ValueNotifier<bool>(true);
  static bool get ar => isArabic.value;
  static void toggle() => isArabic.value = !isArabic.value;
}


String tr(String ar, String en) => Lang.ar ? ar : en;

const _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
];
const _monthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String fmtDate(DateTime d) => Lang.ar
    ? '${d.day} ${_monthsAr[d.month - 1]}'
    : '${_monthsEn[d.month - 1]} ${d.day}';

String fmtTime(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute == 0 ? '' : ':${d.minute.toString().padLeft(2, '0')}';
  final isAm = d.hour < 12;
  if (Lang.ar) return '$h12$m ${isAm ? 'صباحاً' : 'مساءً'}';
  return '$h12$m ${isAm ? 'AM' : 'PM'}';
}
