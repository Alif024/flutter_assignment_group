import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:flutter_assignment_group/screens/user/widgets/user_bottom_nav.dart';

class UserAssetDetailsPage extends StatelessWidget {
  const UserAssetDetailsPage({
    super.key,
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
            bottomNavigationBar: UserBottomNav(
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
          bottomNavigationBar: UserBottomNav(
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
