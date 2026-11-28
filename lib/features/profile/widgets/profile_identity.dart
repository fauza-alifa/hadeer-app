import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/surface_card.dart';
import '../../auth/auth_providers.dart';
import 'profile_photo.dart';

class ProfileIdentity extends ConsumerWidget {
  const ProfileIdentity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final accentColor = isDark
        ? Color(0xFFA8C5A9)
        : Color(0xFF183D32);

    final badgeColor = isDark
        ? Color(0xFF304B3D)
        : Color(0xFFE8EEE5);

    return SurfaceCard(
      padding: 22,
      child: Column(
        children: [
          ProfilePhoto(),

          Text(
            ref.watch(studentNameProvider),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),

          SizedBox(height: 10),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 15, color: accentColor),
                SizedBox(width: 7),
                Text(
                  'Akun siswi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
