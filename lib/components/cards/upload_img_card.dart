import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImgCard extends StatefulWidget {
  const UploadImgCard({
    super.key,
    this.onTap,
    this.onImageSelected,
    this.onPickError,
    this.title = 'Tap to upload image',
    this.subtitle = 'JPG, PNG or JPEG (max. 5MB)',
    this.height = 260,
    this.maxFileSizeMb = 5,
    this.backgroundColor = const Color(0xFFF5F7FA),
    this.borderColor = const Color(0xFFDCE3EE),
    this.iconColor = const Color(0xFF2563EB),
  });

  final VoidCallback? onTap;
  final ValueChanged<XFile?>? onImageSelected;
  final ValueChanged<String>? onPickError;
  final String title;
  final String subtitle;
  final double height;
  final int maxFileSizeMb;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  @override
  State<UploadImgCard> createState() => _UploadImgCardState();
}

class _UploadImgCardState extends State<UploadImgCard> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  bool _isPressed = false;
  bool _isPicking = false;

  Future<void> _pickImage() async {
    widget.onTap?.call();
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final maxBytes = widget.maxFileSizeMb * 1024 * 1024;
      final length = await file.length();
      if (length > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File too large. Max ${widget.maxFileSizeMb}MB.'),
            ),
          );
        }
        widget.onPickError?.call('File too large');
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() {
        _selectedImageBytes = bytes;
      });
      widget.onImageSelected?.call(file);
    } catch (_) {
      widget.onPickError?.call('Unable to pick image');
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pickImage,
          onHighlightChanged: (value) {
            setState(() {
              _isPressed = value;
            });
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: CustomPaint(
              painter: _DashedRoundedBorderPainter(
                borderRadius: 22,
                color: widget.borderColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: _selectedImageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isPicking
                                  ? SizedBox(
                                      width: 38,
                                      height: 38,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: widget.iconColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 52,
                                      color: widget.iconColor,
                                    ),
                              const SizedBox(height: 18),
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF182033),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
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
        final nextDistance = (distance + dashWidth)
            .clamp(0, metric.length)
            .toDouble();
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
