import 'package:flutter/material.dart';
import 'package:hadeer_app/core/hadeer_mark.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hadeer Logo and Brand Name
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hadeer Logo
            HadeerMark(size: 76),

            SizedBox(height: 12),

            // Brand Name
            Text(
              'hadeer',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.2,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),

        SizedBox(height: 32),

        // Welcome Title
        Text(
          'Selamat datang.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -1.2,
            color: scheme.onSurface,
          ),
        ),

        SizedBox(height: 10),

        // Description
        Text(
          'Masuk untuk mencatat kehadiranmu hari ini.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: scheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 28),
      ],
    );
  }
}
