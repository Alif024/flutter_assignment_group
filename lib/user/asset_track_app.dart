import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/cards/recent_activity_card.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_activity_record.dart';
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

class _UserRepairsPage extends StatefulWidget {
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
  State<_UserRepairsPage> createState() => _UserRepairsPageState();
}

class _UserRepairsPageState extends State<_UserRepairsPage> {
  String _query = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(
        title: 'My Repairs',
        showBack: false,
        action: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<AssetActivityRecord>>(
        stream: widget.repository.watchActivities(limit: 2000),
        builder: (context, activitySnapshot) {
          final activities = activitySnapshot.data ?? const <AssetActivityRecord>[];
          final submittedRepairAssetIds = activities
              .where(
                (log) =>
                    log.actorEmployeeId == widget.employeeId &&
                    log.toStatus == 'under_repair',
              )
              .map((log) => log.assetId)
              .where((assetId) => assetId.trim().isNotEmpty)
              .toSet();

          return StreamBuilder<List<AssetRecord>>(
            stream: widget.repository.watchAssets(),
            builder: (context, assetsSnapshot) {
              final assets = assetsSnapshot.data ?? const <AssetRecord>[];
              final mySubmittedAssets = assets
                  .where((asset) => submittedRepairAssetIds.contains(asset.assetCode))
                  .toList();
              final results = _applyFilter(mySubmittedAssets);

              if ((activitySnapshot.connectionState == ConnectionState.waiting &&
                      submittedRepairAssetIds.isEmpty) ||
                  (assetsSnapshot.connectionState == ConnectionState.waiting &&
                      mySubmittedAssets.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                  child: Column(
                    children: [
                      _UserSearchField(
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      const SizedBox(height: 12),
                      _UserStatusChips(
                        value: _statusFilter,
                        onChanged: (value) =>
                            setState(() => _statusFilter = value),
                      ),
                      const SizedBox(height: 12),
                      SurfaceCard(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Results: ${results.length}/${mySubmittedAssets.length}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: results.isEmpty
                            ? const Center(
                                child: Text(
                                  'No repair assets found.',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final asset = results[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: RecentActivityCard(
                                      title: asset.name,
                                      activityText: asset.brand,
                                      timeText: asset.assetCode,
                                      statusText: _statusLabel(asset.status),
                                      icon: _typeIcon(asset.type),
                                      statusColor: _statusColor(asset.status),
                                      iconColor: _statusColor(asset.status),
                                      onTap: () =>
                                          widget.onOpenDetail(asset.assetCode),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _UserBottomNav(
        currentIndex: 0,
        onTapRepairs: null,
        onTapScan: widget.onOpenScanTab,
        onTapProfile: widget.onOpenProfileTab,
      ),
    );
  }

  List<AssetRecord> _applyFilter(List<AssetRecord> assets) {
    final normalized = _query.trim().toLowerCase();
    return assets.where((asset) {
      final matchStatus =
          _statusFilter == 'all' ? true : asset.status == _statusFilter;

      final matchText = normalized.isEmpty
          ? true
          : asset.assetCode.toLowerCase().contains(normalized) ||
                asset.name.toLowerCase().contains(normalized) ||
                asset.brand.toLowerCase().contains(normalized) ||
                asset.location.toLowerCase().contains(normalized) ||
                asset.type.toLowerCase().contains(normalized);

      return matchStatus && matchText;
    }).toList();
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

  IconData _typeIcon(String type) {
    switch (type) {
      case 'laptop':
      case 'Laptop':
        return Icons.laptop;
      case 'printer':
      case 'Printer':
        return Icons.print;
      case 'chair':
      case 'Office Chair':
        return Icons.chair;
      default:
        return Icons.widgets;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'under_repair':
        return const Color(0xFFDC2626);
      case 'disposed':
        return const Color(0xFF7C3AED);
      case 'normal':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF2563EB);
    }
  }
}

class _UserSearchField extends StatelessWidget {
  const _UserSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(
                hintText: 'Search by ID, name, brand, type, location',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserStatusChips extends StatelessWidget {
  const _UserStatusChips({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <String, String>{
      'all': 'All',
      'normal': 'Normal',
      'under_repair': 'Under Repair',
      'disposed': 'Disposed',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.entries.map((entry) {
          final isSelected = value == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(entry.value),
              onSelected: (_) => onChanged(entry.key),
              selectedColor: const Color(0xFFDBEAFE),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF1D4ED8) : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
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
