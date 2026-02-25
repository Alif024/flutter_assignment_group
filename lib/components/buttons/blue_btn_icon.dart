import 'package:flutter/material.dart';

class BlueBtnIcon extends StatelessWidget {
  const BlueBtnIcon({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 60,
    this.borderRadius = 14,
    this.iconTextSpacing = 14,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final double iconTextSpacing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: iconTextSpacing)],
            Text(
              text,
              style: const TextStyle(
                fontSize: 24 / 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
