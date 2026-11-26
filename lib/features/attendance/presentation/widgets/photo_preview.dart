import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/surface_card.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, this.photo});

  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final placeholderColor = isDark
        ? const Color(0xFF263F33)
        : const Color(0xFFE8EEE5);

    final iconColor = isDark
        ? const Color(0xFFA8C5A9)
        : const Color(0xFF78947B);

    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return SurfaceCard(
      padding: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: photo != null
              ? Image.memory(
                  photo!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Container(
                  color: placeholderColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.face_retouching_natural_rounded,
                          size: 38,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Foto kehadiranmu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Pratinjau foto akan muncul di sini',
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
