import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadeer_app/features/attendance/domain/attendance.dart';
import 'package:hadeer_app/features/attendance/domain/attendance_policy.dart';
import 'package:hadeer_app/features/attendance/domain/school_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/enter_motion.dart';
import '../../../core/theme_picker.dart';
import '../../../core/surface_card.dart';

import 'calendar_page.dart';
import 'providers.dart';
import 'widgets/history_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  void _openCalendar(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => CalendarPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return EnterMotion(
      child: ListView(
        padding: EdgeInsets.all(24),
        children: [
          SizedBox(height: 16),

          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Jejak hadir',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),

              IconButton(
                onPressed: () => _openCalendar(context),
                tooltip: 'Lihat kalender absensi',
                icon: Icon(Icons.calendar_month_rounded),
                iconSize: 24,
              ),

              SizedBox(width: 4),

              ThemePicker(),
            ],
          ),

          SizedBox(height: 8),

          Text(
            'Perjalanan dan catatan kehadiranmu.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),

          SizedBox(height: 26),

          // Attendance data
          ref
              .watch(attendanceProvider)
              .when(
                data: (items) {
                  final stats = _calculateStats(items);

                  final groupedItems = _groupByMonth(items);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard
                      _AttendanceDashboard(
                        onTime: stats.onTime,
                        late: stats.late,
                        absent: stats.absent,
                      ),

                      SizedBox(height: 30),

                      // Timeline heading
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Riwayat terbaru',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.4,
                              ),
                            ),
                          ),
                          Text(
                            '${items.length} catatan',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      if (items.isEmpty)
                        _emptyState(context)
                      else
                        ...groupedItems.entries.map((entry) {
                          final month = entry.key;
                          final records = entry.value;

                          return _TimelineMonth(month: month, records: records);
                        }),
                    ],
                  );
                },

                loading: () => Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),

                error: (_, _) => Center(
                  child: Column(
                    children: [
                      Text('Riwayat belum bisa dimuat.'),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(attendanceProvider);
                        },
                        child: Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Calculate attendance statistics for the last 30 days.
  _AttendanceStats _calculateStats(List<Attendance> items) {
    final now = AttendancePolicy.wib(DateTime.now());

    final today = DateTime(now.year, now.month, now.day);

    final startDate = today.subtract(Duration(days: 29));

    final attendanceByDay = <String, AttendanceStatus>{};

    for (final item in items) {
      final createdAt = item.createdAt;

      if (createdAt == null) continue;

      final wibTime = AttendancePolicy.wib(createdAt);

      final date = DateTime(wibTime.year, wibTime.month, wibTime.day);

      if (date.isBefore(startDate) || date.isAfter(today)) {
        continue;
      }

      final key = SchoolCalendar.dateKey(date);

      attendanceByDay.putIfAbsent(key, () => AttendancePolicy.status(wibTime));
    }

    final onTime = attendanceByDay.values
        .where((status) => status == AttendanceStatus.onTime)
        .length;

    final late = attendanceByDay.values
        .where((status) => status == AttendanceStatus.late)
        .length;

    int absent = 0;

    for (
      DateTime date = startDate;
      date.isBefore(today);
      date = date.add(Duration(days: 1))
    ) {
      if (!SchoolCalendar.isSchoolDay(date)) continue;

      final key = SchoolCalendar.dateKey(date);

      if (!attendanceByDay.containsKey(key)) {
        absent++;
      }
    }

    return _AttendanceStats(onTime: onTime, late: late, absent: absent);
  }

  // Group history by month.
  Map<String, List<Attendance>> _groupByMonth(List<Attendance> items) {
    final grouped = <String, List<Attendance>>{};

    for (final item in items) {
      final createdAt = item.createdAt;

      final key = createdAt == null
          ? 'unknown'
          : () {
              final date = AttendancePolicy.wib(createdAt);
              return '${date.year}-${date.month.toString().padLeft(2, '0')}';
            }();

      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }

  Widget _emptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 52, color: scheme.onSurfaceVariant),
          SizedBox(height: 16),
          Text(
            'Belum ada absensi.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Kalau sudah di sekolah, absen lewat Beranda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// ATTENDANCE STATISTICS
// --------------------------------------------------

class _AttendanceStats {
  _AttendanceStats({
    required this.onTime,
    required this.late,
    required this.absent,
  });

  final int onTime;
  final int late;
  final int absent;
}

class _AttendanceDashboard extends StatelessWidget {
  _AttendanceDashboard({
    required this.onTime,
    required this.late,
    required this.absent,
  });

  final int onTime;
  final int late;
  final int absent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'RINGKASAN KEHADIRAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Tepat waktu',
                  value: onTime,
                  icon: Icons.check_circle_outline_rounded,
                  color: Color(0xFF78947B),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Telat',
                  value: late,
                  icon: Icons.schedule_rounded,
                  color: Color(0xFFB77D55),
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Absen',
                  value: absent,
                  icon: Icons.cancel_outlined,
                  color: Color(0xFFA6534D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: color),

        SizedBox(height: 10),

        Text(
          '$value',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            height: 1,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 7),

        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// EDITORIAL TIMELINE
// --------------------------------------------------

class _TimelineMonth extends StatelessWidget {
  _TimelineMonth({required this.month, required this.records});

  final String month;
  final List<Attendance> records;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final monthLabel = month == 'unknown'
        ? 'Tanggal tidak tersedia'
        : DateFormat('MMMM yyyy', 'id').format(
            DateTime(
              int.parse(month.split('-')[0]),
              int.parse(month.split('-')[1]),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthLabel.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
            color: scheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 18),

        ...List.generate(records.length, (index) {
          return _TimelineEntry(
            record: records[index],
            isLast: index == records.length - 1,
          );
        }),

        SizedBox(height: 24),
      ],
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  _TimelineEntry({required this.record, required this.isLast});

  final Attendance record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final createdAt = record.createdAt;

    Color markerColor = scheme.outlineVariant;

    if (createdAt != null) {
      final status = AttendancePolicy.status(AttendancePolicy.wib(createdAt));

      markerColor = status == AttendanceStatus.late
          ? Color(0xFFB77D55)
          : Color(0xFF78947B);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: HistoryTile(record: record),
            ),
          ),
        ],
      ),
    );
  }
}
