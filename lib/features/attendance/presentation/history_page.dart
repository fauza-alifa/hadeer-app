import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enter_motion.dart';
import '../../../core/theme_picker.dart';
import 'calendar_page.dart';
import 'providers.dart';
import 'widgets/history_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  void _openCalendar(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CalendarPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnterMotion(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Jejak hadir',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ),

              // Calendar button
              IconButton(
                onPressed: () => _openCalendar(context),
                tooltip: 'Lihat kalender absensi',
                icon: const Icon(Icons.calendar_month_rounded),
                iconSize: 24,
              ),

              const SizedBox(width: 4),

              const ThemePicker(),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'Foto, jam masuk, dan status absenmu.',
            style: TextStyle(),
          ),

          const SizedBox(height: 28),

          // Attendance history
          ...ref
              .watch(attendanceProvider)
              .when(
                data: (items) => items.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 56),
                              SizedBox(height: 18),
                              Text('Belum ada absensi.'),
                              SizedBox(height: 8),
                              Text(
                                'Kalau sudah di sekolah, absen lewat Beranda, ya.',
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ]
                    : items.map((item) => HistoryTile(record: item)).toList(),

                loading: () => [
                  const Center(child: CircularProgressIndicator()),
                ],

                error: (_, _) => [
                  TextButton(
                    onPressed: () {
                      ref.invalidate(attendanceProvider);
                    },
                    child: const Text(
                      'Gagal memuat. Ketuk untuk mencoba lagi.',
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
