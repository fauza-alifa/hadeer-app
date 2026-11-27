import 'package:flutter/material.dart';

import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';
import '../../domain/school_calendar.dart';

class MonthSummary extends StatelessWidget {
  const MonthSummary({super.key, required this.items});

  final List<Attendance> items;

  @override
  Widget build(BuildContext context) {
    final now = AttendancePolicy.wib(DateTime.now());

    // Rentang 30 hari terakhir, termasuk hari ini.
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 29));

    // Simpan satu status absensi untuk setiap tanggal.
    final attendanceByDay = <String, AttendanceStatus>{};

    for (final item in items) {
      final createdAt = item.createdAt;

      if (createdAt == null) continue;

      final wibTime = AttendancePolicy.wib(createdAt);
      final attendanceDate = DateTime(wibTime.year, wibTime.month, wibTime.day);

      if (attendanceDate.isBefore(startDate) || attendanceDate.isAfter(today)) {
        continue;
      }

      final key = SchoolCalendar.dateKey(attendanceDate);

      attendanceByDay.putIfAbsent(key, () => AttendancePolicy.status(wibTime));
    }

    final onTime = attendanceByDay.values
        .where((status) => status == AttendanceStatus.onTime)
        .length;

    final late = attendanceByDay.values
        .where((status) => status == AttendanceStatus.late)
        .length;

    // Hitung hari sekolah yang sudah berlalu tanpa absensi.
    int absent = 0;

    for (
      DateTime date = startDate;
      date.isBefore(today);
      date = date.add(const Duration(days: 1))
    ) {
      if (!SchoolCalendar.isSchoolDay(date)) continue;

      final key = SchoolCalendar.dateKey(date);

      if (!attendanceByDay.containsKey(key)) {
        absent++;
      }
    }

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'CATATANMU',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: scheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 48),

        // Summary
        _summaryRow(
          context,
          icon: Icons.check_circle_outline_rounded,
          label: 'Tepat waktu',
          value: onTime,
          accent: const Color(0xFF78947B),
        ),

        const SizedBox(height: 13),

        _summaryRow(
          context,
          icon: Icons.schedule_rounded,
          label: 'Telat',
          value: late,
          accent: const Color(0xFFB77D55),
        ),

        const SizedBox(height: 13),

        _summaryRow(
          context,
          icon: Icons.cancel_outlined,
          label: 'Absen',
          value: absent,
          accent: const Color(0xFFA6534D),
        ),
      ],
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color accent,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: accent),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(width: 4),

        Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
            height: 1,
          ),
        ),
      ],
    );
  }
}
