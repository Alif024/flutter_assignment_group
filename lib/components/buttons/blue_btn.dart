import 'package:flutter/material.dart';

class BlueBtn extends StatelessWidget {
  const BlueBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 60,
    this.borderRadius = 14,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  static const Color _backgroundColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _backgroundColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _backgroundColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32 / 1.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
