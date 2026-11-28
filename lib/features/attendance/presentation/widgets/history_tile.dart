import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/surface_card.dart';
import '../../domain/attendance_policy.dart';
import '../../domain/attendance.dart';
import '../providers.dart';

class HistoryTile extends ConsumerWidget {
  const HistoryTile({super.key, required this.record});

  final Attendance record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final date = record.createdAt?.toUtc().add(Duration(hours: 7));

    final isLate =
        record.createdAt != null &&
        AttendancePolicy.status(record.createdAt!) == AttendanceStatus.late;

    final statusColor = isLate
        ? Color(0xFFB77D55)
        : Color(0xFF78947B);

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: SurfaceCard(
        padding: 12,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (_) => PhotoDialog(id: record.id),
            );
          },
          child: Row(
            children: [
              // Status icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: dark
                      ? statusColor.withValues(alpha: 0.15)
                      : (isLate
                            ? Color(0xFFF3EAE2)
                            : Color(0xFFE8EEE5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  date == null
                      ? Icons.schedule_rounded
                      : isLate
                      ? Icons.schedule_rounded
                      : Icons.check_rounded,
                  color: date == null ? scheme.onSurfaceVariant : statusColor,
                  size: 20,
                ),
              ),

              SizedBox(width: 13),

              // Attendance details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date == null
                          ? 'Menunggu konfirmasi server'
                          : DateFormat('EEEE, d MMM', 'id').format(date),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      date == null
                          ? 'Menyimpan…'
                          : '${DateFormat('HH:mm:ss').format(date)} WIB',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8),

              // Status and photo indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date == null ? 'Pending' : record.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: date == null
                          ? scheme.onSurfaceVariant
                          : statusColor,
                    ),
                  ),
                  SizedBox(height: 7),
                  Icon(
                    Icons.photo_outlined,
                    size: 17,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotoDialog extends ConsumerWidget {
  PhotoDialog({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Bukti kehadiran',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: ref
          .watch(photoProvider(id))
          .when(
            data: (bytes) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
            loading: () => SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text('Foto belum dapat dimuat.'),
          ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tutup'),
        ),
      ],
    );
  }
}
