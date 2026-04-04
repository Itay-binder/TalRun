// לוח שנה בעברית: שבוע מיום ראשון (א׳) עד שבת (ש׳).

/// אינדקס 0 = ראשון … 6 = שבת
int weekdayIndexFromSunday(DateTime date) {
  final w = date.weekday;
  if (w == DateTime.sunday) return 0;
  return w;
}

DateTime startOfLocalDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// תחילת השבוע (יום ראשון 00:00 מקומי)
DateTime startOfWeekSunday(DateTime date) {
  final d = startOfLocalDay(date);
  return d.subtract(Duration(days: weekdayIndexFromSunday(d)));
}

const kHebrewWeekdayShort = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];
