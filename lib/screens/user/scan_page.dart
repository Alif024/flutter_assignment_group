import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/screens/user/widgets/user_bottom_nav.dart';
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
  );
  final TextEditingController _manualController = TextEditingController();
  bool _isNavigating = false;

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _submitManualCode() {
    final value = _manualController.text.trim();
    if (value.isEmpty) {
      return;
    }
    widget.onOpenAsset(value);
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
    widget.onOpenAsset(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 240,
              child: MobileScanner(
                controller: _controller,
                onDetect: _handleDetect,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitManualCode(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter asset code manually',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _submitManualCode,
            icon: const Icon(Icons.keyboard_alt_outlined),
            label: const Text('Open by code'),
          ),
        ],
      ),
      bottomNavigationBar: UserBottomNav(
        currentIndex: 1,
        onTapRepairs: widget.onOpenRepairsTab,
        onTapScan: null,
        onTapProfile: widget.onOpenProfileTab,
      ),
    );
  }
}
