import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_provider.dart';

class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themeProvider).asData?.value ?? ThemeMode.system;

    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Pilih tema',
      initialValue: selected,
      onSelected: (mode) async {
        try {
          await ref.read(themeProvider.notifier).setMode(mode);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tampilan belum tersimpan. Coba lagi, ya.'),
              ),
            );
          }
        }
      },
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: scheme.surface,
      elevation: 4,
      itemBuilder: (context) => [
        _buildMenuItem(
          mode: ThemeMode.light,
          selected: selected,
          icon: Icons.wb_sunny_outlined,
          label: 'Terang',
        ),
        _buildMenuItem(
          mode: ThemeMode.system,
          selected: selected,
          icon: Icons.phone_android_rounded,
          label: 'Ikuti HP',
        ),
        _buildMenuItem(
          mode: ThemeMode.dark,
          selected: selected,
          icon: Icons.nightlight_outlined,
          label: 'Gelap',
        ),
      ],
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: .4),
          ),
        ),
        child: Icon(_icon(selected), size: 20, color: scheme.onSurface),
      ),
    );
  }

  PopupMenuItem<ThemeMode> _buildMenuItem({
    required ThemeMode mode,
    required ThemeMode selected,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selected == mode;

    return PopupMenuItem<ThemeMode>(
      value: mode,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;

          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: .12)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 18, color: scheme.primary),
            ],
          );
        },
      ),
    );
  }

  IconData _icon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.phone_android_rounded,
    ThemeMode.light => Icons.wb_sunny_outlined,
    ThemeMode.dark => Icons.nightlight_outlined,
  };
}
