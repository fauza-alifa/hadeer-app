class SchoolCalendar {
  SchoolCalendar._();

  static const Set<String> holidays = {'2026-12-25', '2027-01-01'};

  static String dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static bool isWeekday(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  static bool isHoliday(DateTime date) {
    return holidays.contains(dateKey(date));
  }

  static bool isSchoolDay(DateTime date) {
    return isWeekday(date) && !isHoliday(date);
  }
}
