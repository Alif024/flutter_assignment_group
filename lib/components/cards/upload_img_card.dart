import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImgCardController {
  Future<void> Function()? _pickFromCamera;

  Future<void> pickFromCamera() async {
    await _pickFromCamera?.call();
  }
}

class UploadImgCard extends StatefulWidget {
  const UploadImgCard({
    super.key,
    this.controller,
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
    this.showCameraButton = false,
  });

  final UploadImgCardController? controller;
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
  final bool showCameraButton;

  @override
  State<UploadImgCard> createState() => _UploadImgCardState();
}

class _UploadImgCardState extends State<UploadImgCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImageFile;
  bool _isPressed = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant UploadImgCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._pickFromCamera = null;
      _attachController(widget.controller);
    }
  }

  void _attachController(UploadImgCardController? controller) {
    if (controller == null) {
      return;
    }
    controller._pickFromCamera = () => _pickImageFrom(ImageSource.camera);
  }

  @override
  void dispose() {
    if (widget.controller?._pickFromCamera != null) {
      widget.controller!._pickFromCamera = null;
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    await _pickImageFrom(ImageSource.gallery);
  }

  Future<void> _pickImageFrom(ImageSource source) async {
    widget.onTap?.call();
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) {
        return;
      }

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

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImageFile = file;
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
          child: Stack(
            children: [
              Container(
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
                    child: _selectedImageFile != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFC9D5E6),
                                    width: 1.3,
                                  ),
                                  color: const Color(0xFFF0F4FA),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.file(
                                    File(_selectedImageFile!.path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
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
              if (widget.showCameraButton)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white,
                    elevation: 1,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Take photo',
                      icon: const Icon(Icons.photo_camera_outlined),
                      onPressed: _isPicking
                          ? null
                          : () => _pickImageFrom(ImageSource.camera),
                    ),
                  ),
                ),
            ],
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
