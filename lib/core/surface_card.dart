import 'package:flutter/material.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = 18,
    this.tint,
  });

  final Widget child;
  final double padding;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:
            tint ?? (dark ? const Color(0xFF1B332B) : const Color(0xFFFAFBF9)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? const Color(0xFF53675B).withValues(alpha: 0.2)
              : const Color(0xFFE9ECE7).withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.10)
                : const Color(0xFF263A30).withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
