import 'package:flutter/material.dart';

class AssetDetailRow extends StatelessWidget {
  const AssetDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF111827),
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: const Color(0xFF2D66DF), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 34 / 1.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

