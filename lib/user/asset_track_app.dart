import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:flutter_assignment_group/screens/admin/scan_qr_page.dart';
import 'package:flutter_assignment_group/screens/profile_page.dart';

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
          onOpenScan: () => _goTo(_UserPage.scan),
          onOpenProfile: () => _goTo(_UserPage.profile),
          onLogout: widget.onLogout,
        );
      case _UserPage.scan:
        return ScanQrPage(
          onBack: () => _goTo(_UserPage.repairs),
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
            onOpenScan: () => _goTo(_UserPage.scan),
            onOpenProfile: () => _goTo(_UserPage.profile),
            onLogout: widget.onLogout,
          );
        }
        return _UserAssetDetailsPage(
          repository: widget.repository,
          assetCode: assetCode,
          onBack: () => _goTo(_UserPage.repairs),
        );
      case _UserPage.profile:
        return ProfilePage(
          repository: widget.repository,
          employeeId: widget.employeeId,
          onOpenDashboard: () => _goTo(_UserPage.repairs),
          onOpenSearch: () => _goTo(_UserPage.scan),
          onAddAsset: () {},
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
    required this.onOpenScan,
    required this.onOpenProfile,
    required this.onLogout,
  });

  final FirestoreRepository repository;
  final String employeeId;
  final ValueChanged<String> onOpenDetail;
  final VoidCallback onOpenScan;
  final VoidCallback onOpenProfile;
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onOpenScan,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpenProfile,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Profile'),
                      ),
                    ),
                  ],
                ),
              ),
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
  });

  final FirestoreRepository repository;
  final String assetCode;
  final VoidCallback onBack;

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
