import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_providers.dart';
import '../../../core/brand_header.dart';
import '../../../core/enter_motion.dart';
import 'providers.dart';
import 'widgets/clock_card.dart';
import 'widgets/check_in_card.dart';
import 'widgets/month_summary.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return EnterMotion(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const BrandHeader(),

          const SizedBox(height: 26),

          Text(
            'Hai, ${ref.watch(studentNameProvider).split(' ').first}.',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -.8,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Sudah sampai? Absen dulu yuk!',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),

          const SizedBox(height: 28),

          const ClockCard(),

          const SizedBox(height: 20),

          // Check-in dan ringkasan absensi
          ref
              .watch(attendanceProvider)
              .when(
                data: (items) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 5, child: CheckInCard()),

                      const SizedBox(width: 16),

                      Expanded(flex: 5, child: MonthSummary(items: items)),
                    ],
                  );
                },

                loading: () => const Center(child: LinearProgressIndicator()),

                error: (_, _) =>
                    const Text('Catatan belum bisa dimuat. Cek koneksimu, ya.'),
              ),
        ],
      ),
    );
  }
}
