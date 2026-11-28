import 'package:flutter/material.dart';

class ScanEmblem extends StatelessWidget {
  const ScanEmblem({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark
        ? Color(0xFFA8C5A9)
        : Color(0xFF183D32);

    final backgroundColor = isDark
        ? Color(0xFF263F33)
        : Color(0xFFE8EEE5);

    final borderColor = isDark
        ? Color(0xFF53675B)
        : Color(0xFFD5DED2);

    return SizedBox(
      width: 96,
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main icon container
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Icon(
              Icons.face_retouching_natural_rounded,
              size: 32,
              color: primaryColor,
            ),
          ),

          // Confirmation indicator
          Positioned(
            right: 7,
            bottom: 3,
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: Color(0xFF78947B),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isDark
                      ? Color(0xFF1B332B)
                      : Color(0xFFFAFBF9),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),

          // Decorative accent
          Positioned(
            left: 5,
            top: 10,
            child: Icon(
              Icons.add_rounded,
              size: 16,
              color: primaryColor.withValues(alpha: 0.55),
            ),
          ),

          Positioned(
            right: 5,
            top: 12,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Color(0xFF78947B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
