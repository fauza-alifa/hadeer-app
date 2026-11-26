import 'package:flutter/material.dart';

import '../../../../core/surface_card.dart';
import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';

class MonthSummary extends StatelessWidget {
  const MonthSummary({super.key, required this.items});

  final List<Attendance> items;

  @override
  Widget build(BuildContext context) {
    final confirmed = items.where((item) => item.createdAt != null).toList();

    final late = confirmed
        .where(
          (item) =>
              AttendancePolicy.status(item.createdAt!) == AttendanceStatus.late,
        )
        .length;

    final onTime = confirmed.length - late;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _tile(
                context,
                value: '$onTime',
                label: 'Tepat waktu',
                icon: Icons.check_rounded,
                accent: const Color(0xFF78947B),
                iconBackground: const Color(0xFFE8EEE5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tile(
                context,
                value: '$late',
                label: 'Telat',
                icon: Icons.schedule_rounded,
                accent: const Color(0xFFB77D55),
                iconBackground: const Color(0xFFF3EAE2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          'Dari ${confirmed.length} absensi terakhir.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
    required Color iconBackground,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SurfaceCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dark ? accent.withValues(alpha: 0.16) : iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: dark ? accent : accent, size: 19),
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              height: 1,
              color: scheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
