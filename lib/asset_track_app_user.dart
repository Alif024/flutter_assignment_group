import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/screens/admin/add_asset_page.dart';
import 'package:flutter_assignment_group/screens/admin/edit_asset_page.dart';
import 'package:flutter_assignment_group/screens/user/asset_details_page.dart';
import 'package:flutter_assignment_group/screens/user/my_repairs_page.dart';
import 'package:flutter_assignment_group/screens/user/profile_page.dart';
import 'package:flutter_assignment_group/screens/user/scan_page.dart';

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

enum _UserPage { repairs, scan, addAsset, editAsset, details, profile }

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

  @override
  Widget build(BuildContext context) {
    switch (_currentPage) {
      case _UserPage.repairs:
        return UserMyRepairsPage(
          repository: widget.repository,
          employeeId: widget.employeeId,
          onOpenDetail: (assetCode) =>
              _goTo(_UserPage.details, selectedAssetCode: assetCode),
          onAddAsset: () =>
              _goTo(_UserPage.addAsset, clearSelectedAssetCode: true),
          onOpenScanTab: () => _goTo(_UserPage.scan),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
          onLogout: widget.onLogout,
        );
      case _UserPage.scan:
        return UserScanPage(
          onBack: () => _goTo(_UserPage.repairs),
          onOpenRepairsTab: () => _goTo(_UserPage.repairs),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
          onOpenAsset: _openAsset,
        );
      case _UserPage.details:
        final assetCode = _selectedAssetCode;
        if (assetCode == null) {
          return UserMyRepairsPage(
            repository: widget.repository,
            employeeId: widget.employeeId,
            onOpenDetail: (code) =>
                _goTo(_UserPage.details, selectedAssetCode: code),
            onAddAsset: () =>
                _goTo(_UserPage.addAsset, clearSelectedAssetCode: true),
            onOpenScanTab: () => _goTo(_UserPage.scan),
            onOpenProfileTab: () => _goTo(_UserPage.profile),
            onLogout: widget.onLogout,
          );
        }
        return UserAssetDetailsPage(
          repository: widget.repository,
          assetCode: assetCode,
          actorEmployeeId: widget.employeeId,
          onBack: () => _goTo(_UserPage.repairs),
          onEdit: (code) => _goTo(_UserPage.editAsset, selectedAssetCode: code),
          onOpenRepairsTab: () => _goTo(_UserPage.repairs),
          onOpenScanTab: () => _goTo(_UserPage.scan),
          onOpenProfileTab: () => _goTo(_UserPage.profile),
        );
      case _UserPage.addAsset:
        return AddAssetPage(
          repository: widget.repository,
          onBack: () => _goTo(_UserPage.repairs, clearSelectedAssetCode: true),
          actorEmployeeId: widget.employeeId,
          initialAssetCode: _selectedAssetCode,
          onSaved: (assetCode) =>
              _goTo(_UserPage.details, selectedAssetCode: assetCode),
        );
      case _UserPage.editAsset:
        final assetCode = _selectedAssetCode;
        if (assetCode == null) {
          return UserMyRepairsPage(
            repository: widget.repository,
            employeeId: widget.employeeId,
            onOpenDetail: (code) =>
                _goTo(_UserPage.details, selectedAssetCode: code),
            onAddAsset: () =>
                _goTo(_UserPage.addAsset, clearSelectedAssetCode: true),
            onOpenScanTab: () => _goTo(_UserPage.scan),
            onOpenProfileTab: () => _goTo(_UserPage.profile),
            onLogout: widget.onLogout,
          );
        }
        return EditAssetPage(
          repository: widget.repository,
          assetCode: assetCode,
          onBack: () => _goTo(_UserPage.details, selectedAssetCode: assetCode),
          actorEmployeeId: widget.employeeId,
          onSaved: (code) => _goTo(_UserPage.details, selectedAssetCode: code),
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
}
