import 'package:flutter/material.dart';

class BlueBtn extends StatelessWidget {
  const BlueBtn({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 60,
    this.borderRadius = 10,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  double get _fontSize {
    final dynamicSize = height * 0.3;
    return dynamicSize.clamp(14.0, 20.0);
  }

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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
