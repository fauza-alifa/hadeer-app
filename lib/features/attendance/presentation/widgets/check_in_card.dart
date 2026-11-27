import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/clock_provider.dart';
import '../../domain/attendance.dart';
import '../../domain/attendance_policy.dart';
import '../providers.dart';
import '../capture_page.dart';

class CheckInCard extends ConsumerWidget {
  const CheckInCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(attendanceProvider);

    final now = AttendancePolicy.wib(
      ref.watch(clockProvider).asData?.value ?? DateTime.now(),
    );

    Attendance? today;

    for (final record in records.asData?.value ?? <Attendance>[]) {
      final date = record.createdAt == null
          ? null
          : AttendancePolicy.wib(record.createdAt!);

      if (date?.year == now.year &&
          date?.month == now.month &&
          date?.day == now.day) {
        today = record;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final isCheckedIn = today != null;

    final buttonColor = isDark
        ? (isCheckedIn ? const Color(0xFF78947B) : const Color(0xFFA8C5A9))
        : (isCheckedIn ? const Color(0xFF78947B) : const Color(0xFF183D32));

    final buttonTextColor = isDark && !isCheckedIn
        ? const Color(0xFF102A23)
        : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'KEHADIRAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCheckedIn || !records.hasValue
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CapturePage(),
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCheckedIn
                        ? Icons.check_circle_outline_rounded
                        : Icons.touch_app_rounded,
                    size: 44,
                    color: buttonTextColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isCheckedIn ? 'Checked-in' : 'Check-in',
                    style: TextStyle(
                      color: buttonTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (records.hasError) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(attendanceProvider),
            child: const Text('Try again'),
          ),
        ],
      ],
    );
  }
}
