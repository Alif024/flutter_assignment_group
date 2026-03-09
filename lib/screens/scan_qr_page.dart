import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({
    super.key,
    required this.onBack,
    required this.onOpenAsset,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onOpenAsset;

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.code128,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf14,
      BarcodeFormat.codabar,
      BarcodeFormat.pdf417,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.aztec,
    ],
  );

  String? _lastCode;
  bool _isHandlingCode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isHandlingCode) {
      return;
    }

    final barcode = capture.barcodes.firstOrNull;
    final value = (barcode?.displayValue ?? barcode?.rawValue ?? '').trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _lastCode = value;
      _isHandlingCode = true;
    });

    _controller.stop();
    widget.onOpenAsset(value);
  }

  void _openScannedAsset() {
    final value = _lastCode;
    if (value == null || value.isEmpty) {
      return;
    }
    widget.onOpenAsset(value);
  }

  Future<void> _scanAgain() async {
    await _controller.start();
    if (!mounted) {
      return;
    }

    setState(() {
      _isHandlingCode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(
        title: 'Scan Barcode',
        onBack: widget.onBack,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.black,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _handleBarcode,
                        errorBuilder: (context, error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Camera error: ${error.errorCode.name}',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScanFramePainter(),
                        ),
                      ),
                      const Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          'Place barcode inside the frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Latest Scan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastCode ?? 'No barcode scanned yet.',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isHandlingCode ? _scanAgain : null,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan Again'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _lastCode == null ? null : _openScannedAsset,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open Asset'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameColor = Color(0xCCFFFFFF);
    const strokeWidth = 4.0;
    const corner = 28.0;
    final center = Offset(size.width / 2, size.height / 2);
    final frameWidth = size.width * 0.74;
    final frameHeight = size.height * 0.40;
    final rect = Rect.fromCenter(
      center: center,
      width: frameWidth,
      height: frameHeight,
    );

    final paint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(rect.left, rect.top + corner)
      ..lineTo(rect.left, rect.top)
      ..lineTo(rect.left + corner, rect.top)
      ..moveTo(rect.right - corner, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right, rect.top + corner)
      ..moveTo(rect.left, rect.bottom - corner)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left + corner, rect.bottom)
      ..moveTo(rect.right - corner, rect.bottom)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.right, rect.bottom - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
