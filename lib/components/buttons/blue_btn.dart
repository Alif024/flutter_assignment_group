import 'package:flutter/material.dart';

class BlueBtn extends StatelessWidget {
  const BlueBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
    this.borderRadius = 10,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24 / 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
