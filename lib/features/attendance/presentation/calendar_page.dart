import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/surface_card.dart';
import '../domain/attendance.dart';
import '../domain/attendance_policy.dart';
import '../domain/attendance_day_status.dart';
import 'providers.dart';
import 'widgets/history_tile.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime selectedMonth;
  late DateTime selectedDate;

  static Color onTimeColor = Color(0xFF78947B);
  static Color lateColor = Color(0xFFB77D55);
  static Color absentColor = Color(0xFFA6534D);

  @override
  void initState() {
    super.initState();

    final today = AttendancePolicy.wib(DateTime.now());

    selectedMonth = DateTime(today.year, today.month);
    selectedDate = DateTime(today.year, today.month, today.day);
  }

  String get monthKey => AttendanceCalendarUtils.monthKey(selectedMonth);

  void _changeMonth(int offset) {
    final newMonth = DateTime(selectedMonth.year, selectedMonth.month + offset);

    final today = AttendancePolicy.wib(DateTime.now());
    final currentMonth = DateTime(today.year, today.month);

    if (newMonth.isAfter(currentMonth)) return;

    setState(() {
      selectedMonth = newMonth;
      selectedDate = DateTime(newMonth.year, newMonth.month, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  AttendanceDayStatus _getDateStatus({
    required DateTime date,
    required List<Attendance> records,
    required DateTime now,
  }) {
    final dayRecords = AttendanceCalendarUtils.recordsForDate(records, date);

    final record = dayRecords.isNotEmpty ? dayRecords.first : null;

    return AttendanceDayStatusResolver.resolve(
      date: date,
      now: now,
      attendanceTime: record?.createdAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final attendanceAsync = ref.watch(monthlyAttendanceProvider(monthKey));

    final today = AttendancePolicy.wib(DateTime.now());

    final forest = dark ? Color(0xFFA8C5A9) : Color(0xFF183D32);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kalender absensi',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 56),
        children: [
          SurfaceCard(
            padding: 18,
            child: Column(
              children: [
                // Month navigation
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      tooltip: 'Bulan sebelumnya',
                      icon: Icon(Icons.chevron_left_rounded),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          DateFormat('MMMM yyyy', 'id').format(selectedMonth),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          DateTime(
                            selectedMonth.year,
                            selectedMonth.month + 1,
                          ).isAfter(DateTime(today.year, today.month))
                          ? null
                          : () => _changeMonth(1),
                      tooltip: 'Bulan berikutnya',
                      icon: Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),

                SizedBox(height: 18),

                // Weekday labels: Sunday first
                Row(
                  children: [
                    _WeekdayLabel('Min'),
                    _WeekdayLabel('Sen'),
                    _WeekdayLabel('Sel'),
                    _WeekdayLabel('Rab'),
                    _WeekdayLabel('Kam'),
                    _WeekdayLabel('Jum'),
                    _WeekdayLabel('Sab'),
                  ],
                ),

                SizedBox(height: 12),

                // Calendar grid
                attendanceAsync.when(
                  data: (records) {
                    return _buildCalendar(
                      records: records,
                      today: today,
                      forest: forest,
                    );
                  },
                  loading: () => SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 30,
                            color: scheme.onSurfaceVariant,
                          ),
                          SizedBox(height: 10),
                          Text('Gagal memuat kalender.'),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(
                                monthlyAttendanceProvider(monthKey),
                              );
                            },
                            child: Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Calendar legend
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    _LegendItem(color: onTimeColor, label: 'Tepat waktu'),
                    _LegendItem(color: lateColor, label: 'Terlambat'),
                    _LegendItem(color: absentColor, label: 'Tidak masuk'),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 22),

          // Selected date details
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detail tanggal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy', 'id').format(selectedDate),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),

          SizedBox(height: 14),

          attendanceAsync.when(
            data: (records) {
              final selectedRecords = AttendanceCalendarUtils.recordsForDate(
                records,
                selectedDate,
              );

              final status = _getDateStatus(
                date: selectedDate,
                records: records,
                now: DateTime.now(),
              );

              if (selectedRecords.isNotEmpty) {
                return Column(
                  children: selectedRecords
                      .map((record) => HistoryTile(record: record))
                      .toList(),
                );
              }

              return _buildEmptyDateDetail(status);
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar({
    required List<Attendance> records,
    required DateTime today,
    required Color forest,
  }) {
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;

    // Sunday first:
    // Sunday = 0, Monday = 1, ..., Saturday = 6.
    final firstDayOffset = AttendanceCalendarUtils.sundayFirstOffset(
      selectedMonth,
    );

    final totalCells = firstDayOffset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 52,
      ),
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return SizedBox.shrink();
        }

        final day = index - firstDayOffset + 1;

        final date = DateTime(selectedMonth.year, selectedMonth.month, day);

        final status = _getDateStatus(
          date: date,
          records: records,
          now: DateTime.now(),
        );

        final hasAttendance =
            status == AttendanceDayStatus.onTime ||
            status == AttendanceDayStatus.late;

        final isAbsent = status == AttendanceDayStatus.absent;

        final isSelected =
            selectedDate.year == date.year &&
            selectedDate.month == date.month &&
            selectedDate.day == date.day;

        final isToday =
            today.year == date.year &&
            today.month == date.month &&
            today.day == date.day;

        final Color backgroundColor;

        if (isSelected) {
          backgroundColor = forest;
        } else {
          backgroundColor = switch (status) {
            AttendanceDayStatus.onTime => onTimeColor,
            AttendanceDayStatus.late => lateColor,
            AttendanceDayStatus.absent => absentColor,
            _ => Colors.transparent,
          };
        }

        final hasStatusColor = hasAttendance || isAbsent;

        final textColor = isSelected || hasStatusColor
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectDate(date),
          child: Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: isToday ? Border.all(color: forest, width: 2) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected || isToday || hasStatusColor
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDateDetail(AttendanceDayStatus status) {
    final scheme = Theme.of(context).colorScheme;

    final String title;
    final String description;
    final IconData icon;
    final Color iconColor;

    switch (status) {
      case AttendanceDayStatus.absent:
        title = 'Tidak masuk';
        description = 'Tidak ada catatan kehadiran pada tanggal ini.';
        icon = Icons.event_busy_outlined;
        iconColor = absentColor;

      case AttendanceDayStatus.holiday:
        title = 'Hari libur';
        description = 'Tanggal ini termasuk dalam daftar hari libur sekolah.';
        icon = Icons.celebration_outlined;
        iconColor = scheme.onSurfaceVariant;

      case AttendanceDayStatus.weekend:
        title = 'Akhir pekan';
        description = 'Tidak ada kegiatan sekolah pada hari ini.';
        icon = Icons.weekend_outlined;
        iconColor = scheme.onSurfaceVariant;

      case AttendanceDayStatus.upcoming:
        title = 'Belum ada catatan absensi';
        description = 'Belum ada data kehadiran pada tanggal ini.';
        icon = Icons.event_available_outlined;
        iconColor = scheme.onSurfaceVariant;

      case AttendanceDayStatus.onTime:
      case AttendanceDayStatus.late:
        title = 'Belum ada catatan absensi';
        description = 'Tidak ditemukan data absensi pada tanggal ini.';
        icon = Icons.event_available_outlined;
        iconColor = scheme.onSurfaceVariant;
    }

    return SurfaceCard(
      padding: 24,
      child: Column(
        children: [
          Icon(icon, size: 38, color: iconColor),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

abstract final class AttendanceCalendarUtils {
  static String monthKey(DateTime month) {
    final monthString = month.month.toString().padLeft(2, '0');

    return '${month.year}-$monthString';
  }

  /// Menghitung offset dengan Minggu sebagai hari pertama.
  ///
  /// Sunday = 0
  /// Monday = 1
  /// Tuesday = 2
  /// Wednesday = 3
  /// Thursday = 4
  /// Friday = 5
  /// Saturday = 6
  static int sundayFirstOffset(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday % 7;
  }

  static DateTime wibDate(DateTime instant) {
    final wib = AttendancePolicy.wib(instant);

    return DateTime(wib.year, wib.month, wib.day);
  }

  static List<Attendance> recordsForDate(
    Iterable<Attendance> records,
    DateTime date,
  ) {
    return records.where((record) {
      final createdAt = record.createdAt;

      if (createdAt == null) return false;

      final attendanceDate = wibDate(createdAt);

      return attendanceDate.year == date.year &&
          attendanceDate.month == date.month &&
          attendanceDate.day == date.day;
    }).toList();
  }
}
