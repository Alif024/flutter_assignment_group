import 'package:flutter/material.dart';

class UploadImgCard extends StatelessWidget {
  const UploadImgCard({
    super.key,
    this.onTap,
    this.title = 'Tap to upload image',
    this.subtitle = 'JPG, PNG or JPEG (max. 5MB)',
    this.height = 260,
    this.backgroundColor = const Color(0xFFF5F7FA),
    this.borderColor = const Color(0xFFDCE3EE),
    this.iconColor = const Color(0xFF2563EB),
  });

  final VoidCallback? onTap;
  final String title;
  final String subtitle;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: CustomPaint(
            painter: _DashedRoundedBorderPainter(
              borderRadius: 22,
              color: borderColor,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      size: 52,
                      color: iconColor,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40 / 2,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF182033),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34 / 2,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF182033),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.borderRadius,
    required this.color,
  });

  final double borderRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDistance =
            (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.color != color;
  }
}
