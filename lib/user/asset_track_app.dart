import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:flutter_assignment_group/screens/user/profile_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class UserAssetTrackShell extends StatefulWidget {
  const UserAssetTrackShell({
    super.key,
    required this.repository,
    required this.employeeId,
    required this.onLogout,
  });

  final FirestoreRepository repository;
  final String employeeId;
  final VoidCallback onLogout;

  @override
  State<UserAssetTrackShell> createState() => _UserAssetTrackShellState();
}

enum _UserPage { repairs, scan, details, profile }

class _UserAssetTrackShellState extends State<UserAssetTrackShell> {
  _UserPage _currentPage = _UserPage.repairs;
  String? _selectedAssetCode;

  void _goTo(
    _UserPage page, {
    String? selectedAssetCode,
    bool clearSelectedAssetCode = false,
  }) {
    setState(() {
      if (clearSelectedAssetCode) {
        _selectedAssetCode = null;
      }
      if (selectedAssetCode != null) {
        _selectedAssetCode = selectedAssetCode;
      }
      _currentPage = page;
    });
  }

  Future<void> _openAsset(String code) async {
    final value = code.trim();
    if (value.isEmpty) {
      return;
    }

    final asset = await widget.repository.getAsset(value);
    if (!mounted) {
      return;
    }

    if (asset == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Asset not found.')));
      return;
    }

    _goTo(_UserPage.details, selectedAssetCode: value);
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case _UserPage.repairs:
        return _UserRepairsPage(
          repository: widget.repository,
          employeeId: widget.employeeId,
          onOpenDetail: (assetCode) =>
              _goTo(_UserPage.details, selectedAssetCode: assetCode),
          onOpenScanTab: () => _goTo(_UserPage.scan),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
          onLogout: widget.onLogout,
        );
      case _UserPage.scan:
        return _UserScanPage(
          onBack: () => _goTo(_UserPage.repairs),
          onOpenRepairsTab: () => _goTo(_UserPage.repairs),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
          onOpenAsset: _openAsset,
        );
      case _UserPage.details:
        final assetCode = _selectedAssetCode;
        if (assetCode == null) {
          return _UserRepairsPage(
            repository: widget.repository,
            employeeId: widget.employeeId,
            onOpenDetail: (code) =>
                _goTo(_UserPage.details, selectedAssetCode: code),
            onOpenScanTab: () => _goTo(_UserPage.scan),
            onOpenProfileTab: () => _goTo(_UserPage.profile),
            onLogout: widget.onLogout,
          );
        }
        return _UserAssetDetailsPage(
          repository: widget.repository,
          assetCode: assetCode,
          onBack: () => _goTo(_UserPage.repairs),
          onOpenRepairsTab: () => _goTo(_UserPage.repairs),
          onOpenScanTab: () => _goTo(_UserPage.scan),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
        );
      case _UserPage.profile:
        return UserProfilePage(
          repository: widget.repository,
          employeeId: widget.employeeId,
          onOpenRepairs: () => _goTo(_UserPage.repairs),
          onOpenScan: () => _goTo(_UserPage.scan),
          onLogout: widget.onLogout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentPage();
  }
}

class _UserRepairsPage extends StatelessWidget {
  const _UserRepairsPage({
    required this.repository,
    required this.employeeId,
    required this.onOpenDetail,
    required this.onOpenScanTab,
    required this.onOpenProfileTab,
    required this.onLogout,
  });

  final FirestoreRepository repository;
  final String employeeId;
  final ValueChanged<String> onOpenDetail;
  final VoidCallback onOpenScanTab;
  final VoidCallback onOpenProfileTab;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repairs'),
        actions: [
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<List<AssetRecord>>(
        stream: repository.watchAssets(),
        builder: (context, snapshot) {
          final assets = snapshot.data ?? const <AssetRecord>[];
          final rows = assets
              .where(
                (asset) =>
                    asset.assignedTo == employeeId ||
                    asset.status == 'under_repair',
              )
              .toList();

          if (snapshot.connectionState == ConnectionState.waiting &&
              rows.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: rows.isEmpty
                    ? const Center(
                        child: Text('No assigned or under-repair assets.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: rows.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final asset = rows[index];
                          return Card(
                            child: ListTile(
                              title: Text(asset.name),
                              subtitle: Text(
                                '${asset.assetCode} - ${_statusLabel(asset.status)}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => onOpenDetail(asset.assetCode),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _UserBottomNav(
        currentIndex: 0,
        onTapRepairs: null,
        onTapScan: onOpenScanTab,
        onTapProfile: onOpenProfileTab,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'under_repair':
        return 'Under Repair';
      case 'disposed':
        return 'Disposed';
      case 'normal':
        return 'Normal';
      default:
        return status;
    }
  }
}

class _UserAssetDetailsPage extends StatelessWidget {
  const _UserAssetDetailsPage({
    required this.repository,
    required this.assetCode,
    required this.onBack,
    required this.onOpenRepairsTab,
    required this.onOpenScanTab,
    required this.onOpenProfileTab,
  });

  final FirestoreRepository repository;
  final String assetCode;
  final VoidCallback onBack;
  final VoidCallback onOpenRepairsTab;
  final VoidCallback onOpenScanTab;
  final VoidCallback onOpenProfileTab;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AssetRecord?>(
      stream: repository.watchAsset(assetCode),
      builder: (context, snapshot) {
        final asset = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting && asset == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (asset == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Asset Details'),
              leading: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: const Center(child: Text('Asset not found.')),
            bottomNavigationBar: _UserBottomNav(
              currentIndex: 0,
              onTapRepairs: onOpenRepairsTab,
              onTapScan: onOpenScanTab,
              onTapProfile: onOpenProfileTab,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Asset Details'),
            leading: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _row('Asset ID', asset.assetCode),
              _row('Name', asset.name),
              _row('Type', asset.type),
              _row('Brand', asset.brand),
              _row('Status', _statusLabel(asset.status)),
              _row('Location', asset.location),
              _row('Assigned To', asset.assignedTo ?? '-'),
              _row(
                'Description',
                asset.description.trim().isEmpty ? '-' : asset.description,
              ),
            ],
          ),
          bottomNavigationBar: _UserBottomNav(
            currentIndex: 0,
            onTapRepairs: onOpenRepairsTab,
            onTapScan: onOpenScanTab,
            onTapProfile: onOpenProfileTab,
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value.trim().isEmpty ? '-' : value),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'under_repair':
        return 'Under Repair';
      case 'disposed':
        return 'Disposed';
      case 'normal':
        return 'Normal';
      default:
        return status;
    }
  }
}

class _UserScanPage extends StatefulWidget {
  const _UserScanPage({
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
  State<_UserScanPage> createState() => _UserScanPageState();
}

class _UserScanPageState extends State<_UserScanPage> {
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
      bottomNavigationBar: _UserBottomNav(
        currentIndex: 1,
        onTapRepairs: widget.onOpenRepairsTab,
        onTapScan: null,
        onTapProfile: widget.onOpenProfileTab,
      ),
    );
  }
}

class _UserBottomNav extends StatelessWidget {
  const _UserBottomNav({
    required this.currentIndex,
    required this.onTapRepairs,
    required this.onTapScan,
    required this.onTapProfile,
  });

  final int currentIndex;
  final VoidCallback? onTapRepairs;
  final VoidCallback? onTapScan;
  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          onTapRepairs?.call();
        } else if (index == 1) {
          onTapScan?.call();
        } else if (index == 2) {
          onTapProfile?.call();
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          label: 'Repairs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
