import 'package:flutter/material.dart';

import '../../../../core/surface_card.dart';

class FloatingNav extends StatelessWidget {
  const FloatingNav({super.key, required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).colorScheme.onSurfaceVariant;

    const icons = [
      Icons.grid_view_rounded,
      Icons.receipt_long_rounded,
      Icons.person_rounded,
    ];

    const labels = ['Beranda', 'Riwayat', 'Profil'];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: SurfaceCard(
          padding: 6,
          child: Row(
            children: [
              for (var i = 0; i < icons.length; i++)
                Expanded(
                  child: Semantics(
                    selected: index == i,
                    button: true,
                    label: labels[i],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => onChanged(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: index == i
                              ? (isDark
                                    ? const Color(0xFF304B3D)
                                    : const Color(0xFFE8EEE5))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                icons[i],
                                key: ValueKey(index == i),
                                size: 21,
                                color: index == i ? primary : inactiveColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: index == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: index == i ? primary : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
