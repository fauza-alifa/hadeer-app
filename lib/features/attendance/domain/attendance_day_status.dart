import 'school_calendar.dart';

enum AttendanceDayStatus { onTime, late, absent, holiday, weekend, upcoming }

class AttendanceDayStatusResolver {
  AttendanceDayStatusResolver._();

  static const int deadlineHour = 7;
  static const int deadlineMinute = 0;

  /// Mengubah waktu ke WIB (UTC+7).
  static DateTime toWib(DateTime dateTime) {
    return dateTime.toUtc().add(const Duration(hours: 7));
  }

  /// Membandingkan tanggal dalam WIB.
  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Menentukan status berdasarkan tanggal dan waktu check-in.
  ///
  /// [attendanceTime] null berarti tidak ada catatan check-in.
  /// [now] digunakan untuk menentukan apakah tanggal sudah selesai.
  static AttendanceDayStatus resolve({
    required DateTime date,
    required DateTime now,
    DateTime? attendanceTime,
  }) {
    final targetDate = toWib(date);
    final currentDate = toWib(now);

    if (SchoolCalendar.isHoliday(targetDate)) {
      return AttendanceDayStatus.holiday;
    }

    if (!SchoolCalendar.isWeekday(targetDate)) {
      return AttendanceDayStatus.weekend;
    }

    // Tanggal yang belum tiba tidak memiliki status absensi.
    final targetDay = DateTime.utc(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final currentDay = DateTime.utc(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    if (targetDay.isAfter(currentDay)) {
      return AttendanceDayStatus.upcoming;
    }

    if (attendanceTime != null) {
      final checkIn = toWib(attendanceTime);

      final deadline = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        deadlineHour,
        deadlineMinute,
      );

      return checkIn.isAfter(deadline)
          ? AttendanceDayStatus.late
          : AttendanceDayStatus.onTime;
    }

    // Hari ini baru dianggap tidak masuk setelah pukul 23.59 WIB.
    final endOfDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      23,
      59,
      59,
    );

    if (currentDate.isAfter(endOfDay) ||
        isSameDate(currentDate, targetDate) && currentDate.isAfter(endOfDay)) {
      return AttendanceDayStatus.absent;
    }

    return AttendanceDayStatus.upcoming;
  }
}
