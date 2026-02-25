import 'package:flutter/material.dart';

enum FilledBtnColor { blue, green, gray }

class FilledBtnIcon extends StatelessWidget {
  const FilledBtnIcon({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.height = 60,
    this.borderRadius = 14,
    this.iconTextSpacing = 14,
    this.color = FilledBtnColor.blue,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final double iconTextSpacing;
  final FilledBtnColor color;

  Color get _backgroundColor {
    switch (color) {
      case FilledBtnColor.blue:
        return const Color(0xFF2563EB);
      case FilledBtnColor.green:
        return const Color(0xFF16A34A);
      case FilledBtnColor.gray:
        return const Color(0xFF334155);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
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
            icon!,
            SizedBox(width: iconTextSpacing),
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
