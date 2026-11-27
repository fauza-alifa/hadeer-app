import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/surface_card.dart';
import '../domain/attendance.dart';
import '../domain/attendance_policy.dart';
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final attendanceAsync = ref.watch(monthlyAttendanceProvider(monthKey));

    final today = AttendancePolicy.wib(DateTime.now());

    final forest = dark ? const Color(0xFFA8C5A9) : const Color(0xFF183D32);

    const onTimeColor = Color(0xFF78947B);
    const lateColor = Color(0xFFB77D55);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kalender absensi',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 56),
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
                      icon: const Icon(Icons.chevron_left_rounded),
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
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Weekday labels
                const Row(
                  children: [
                    _WeekdayLabel('Sen'),
                    _WeekdayLabel('Sel'),
                    _WeekdayLabel('Rab'),
                    _WeekdayLabel('Kam'),
                    _WeekdayLabel('Jum'),
                    _WeekdayLabel('Sab'),
                    _WeekdayLabel('Min'),
                  ],
                ),

                const SizedBox(height: 12),

                // Calendar grid
                attendanceAsync.when(
                  data: (records) {
                    return _buildCalendar(
                      records: records,
                      today: today,
                      forest: forest,
                      onTimeColor: onTimeColor,
                      lateColor: lateColor,
                    );
                  },
                  loading: () => const SizedBox(
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
                          const SizedBox(height: 10),
                          const Text('Gagal memuat kalender.'),
                          TextButton(
                            onPressed: () {
                              ref.invalidate(
                                monthlyAttendanceProvider(monthKey),
                              );
                            },
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Calendar legend
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 10,
                  children: const [
                    _LegendItem(color: onTimeColor, label: 'Tepat waktu'),
                    _LegendItem(color: lateColor, label: 'Terlambat'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

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

          const SizedBox(height: 14),

          attendanceAsync.when(
            data: (records) {
              final selectedRecords = AttendanceCalendarUtils.recordsForDate(
                records,
                selectedDate,
              );

              if (selectedRecords.isEmpty) {
                return SurfaceCard(
                  padding: 24,
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 38,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada catatan absensi.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tidak ditemukan data absensi pada tanggal ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: selectedRecords
                    .map((record) => HistoryTile(record: record))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar({
    required List<Attendance> records,
    required DateTime today,
    required Color forest,
    required Color onTimeColor,
    required Color lateColor,
  }) {
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;

    final firstDayOffset = AttendanceCalendarUtils.mondayFirstOffset(
      selectedMonth,
    );

    final totalCells = firstDayOffset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 52,
      ),
      itemBuilder: (context, index) {
        if (index < firstDayOffset) {
          return const SizedBox.shrink();
        }

        final day = index - firstDayOffset + 1;

        final date = DateTime(selectedMonth.year, selectedMonth.month, day);

        final dayRecords = AttendanceCalendarUtils.recordsForDate(
          records,
          date,
        );

        final hasAttendance = dayRecords.isNotEmpty;
        final record = hasAttendance ? dayRecords.first : null;

        final isLate =
            record?.createdAt != null &&
            AttendancePolicy.status(record!.createdAt!) ==
                AttendanceStatus.late;

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
        } else if (hasAttendance) {
          backgroundColor = isLate ? lateColor : onTimeColor;
        } else {
          backgroundColor = Colors.transparent;
        }

        final textColor = isSelected || hasAttendance
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectDate(date),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
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
                  fontWeight: isSelected || isToday || hasAttendance
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
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

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
  const _LegendItem({required this.color, required this.label});

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
        const SizedBox(width: 7),
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

  static int mondayFirstOffset(DateTime month) {
    return DateTime(month.year, month.month, 1).weekday - 1;
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
