import 'package:flutter/material.dart';

enum OutlinedBtnFontColor { navy, red, gray }

class OutlinedBtnIcon extends StatelessWidget {
  const OutlinedBtnIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.height = 60,
    this.borderRadius = 14,
    this.iconTextSpacing = 14,
    this.fontColor = OutlinedBtnFontColor.navy,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double iconTextSpacing;
  final OutlinedBtnFontColor fontColor;

  Color get _contentColor {
    switch (fontColor) {
      case OutlinedBtnFontColor.navy:
        return const Color(0xFF0F172A);
      case OutlinedBtnFontColor.red:
        return const Color(0xFFDC2626);
      case OutlinedBtnFontColor.gray:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAFC),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: _contentColor),
            SizedBox(width: iconTextSpacing),
            Text(
              text,
              style: TextStyle(
                color: _contentColor,
                fontSize: 28 / 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
