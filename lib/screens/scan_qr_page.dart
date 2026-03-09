import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({
    super.key,
    required this.onBack,
    required this.onOpenAsset,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onOpenAsset;

  Future<void> _showManualEntryDialog(BuildContext context) async {
    final controller = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter Asset ID'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'e.g., AST-2024-0156',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final assetId = controller.text.trim();
                  if (assetId.isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop();
                  onOpenAsset(assetId);
                },
                child: const Text('Open'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(title: 'Scan QR Code', onBack: onBack),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF375B9D), Color(0xFF1E3A8A)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Point Camera at QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Camera scanning can be added later.\nUse manual entry now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                            color: Colors.black.withValues(alpha: 0.13),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.white70,
                            size: 46,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: Color(0xFF1E293B),
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showManualEntryDialog(context),
                  icon: const Icon(Icons.keyboard_alt_rounded, size: 18),
                  label: const Text('Enter Asset ID Manually'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
