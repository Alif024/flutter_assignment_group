import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/screens/user/widgets/user_bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class UserScanPage extends StatefulWidget {
  const UserScanPage({
    super.key,
    required this.onBack,
    required this.onOpenAsset,
    required this.onOpenRepairsTab,
    required this.onOpenProfileTab,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onOpenAsset;
  final VoidCallback onOpenRepairsTab;
  final VoidCallback onOpenProfileTab;

  @override
  State<UserScanPage> createState() => _UserScanPageState();
}

class _UserScanPageState extends State<UserScanPage> {
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
  final TextEditingController _manualController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  bool _isProcessingImage = false;
  bool _isNavigating = false;
  String? _imageScanMessage;

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _submitManualCode() {
    _openAssetFromCode(_manualController.text);
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_isNavigating) {
      return;
    }

    final barcode = capture.barcodes.firstOrNull;
    final value = (barcode?.displayValue ?? barcode?.rawValue ?? '').trim();
    if (value.isEmpty) {
      return;
    }

    _isNavigating = true;
    _manualController.text = value;
    _controller.stop();
    _openAssetFromCode(value);
  }

  void _openAssetFromCode(String rawCode) {
    final value = rawCode.trim();
    if (value.isEmpty) {
      return;
    }
    widget.onOpenAsset(value);
  }

  Future<void> _pickAndScanImage() async {
    if (_isProcessingImage) {
      return;
    }

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
      _isProcessingImage = true;
      _imageScanMessage = null;
    });

    try {
      final capture = await _controller.analyzeImage(image.path);
      final barcode = capture?.barcodes.firstOrNull;
      final value = (barcode?.displayValue ?? barcode?.rawValue ?? '').trim();

      if (!mounted) {
        return;
      }

      if (value.isEmpty) {
        setState(() {
          _imageScanMessage = 'No barcode found in selected image.';
        });
        return;
      }

      setState(() {
        _manualController.text = value;
        _imageScanMessage = 'Barcode found: $value';
      });

      _openAssetFromCode(value);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _imageScanMessage =
            'Unable to read this image. Please try another one.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(title: 'Scan Barcode', onBack: widget.onBack),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            children: [
              _buildLiveScannerCard(),
              const SizedBox(height: 12),
              _buildManualEntryCard(),
              const SizedBox(height: 12),
              _buildUploadImageCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: 1,
        onTapRepairs: widget.onOpenRepairsTab,
        onTapScan: null,
        onTapProfile: widget.onOpenProfileTab,
      ),
    );
  }

  Widget _buildLiveScannerCard() {
    return Container(
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
            'Scan QR / Barcode',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _handleDetect,
                    errorBuilder: (context, error) {
                      return Center(
                        child: Text(
                          'Camera error: ${error.errorCode.name}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    },
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Place QR/Barcode inside frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryCard() {
    return Container(
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
            'Enter asset code manually',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitManualCode(),
            decoration: InputDecoration(
              hintText: 'e.g. ASSET-0001',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitManualCode,
              icon: const Icon(Icons.keyboard_alt_outlined),
              label: const Text('Open by code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadImageCard() {
    return Container(
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
            'Upload image from phone',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isProcessingImage ? null : _pickAndScanImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _isProcessingImage ? 'Scanning image...' : 'Choose image',
              ),
            ),
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          if (_imageScanMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _imageScanMessage!,
              style: const TextStyle(color: Color(0xFF4B5563)),
            ),
          ],
        ],
      ),
    );
  }
}
