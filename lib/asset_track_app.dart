import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/screens/add_asset_page.dart';
import 'package:flutter_assignment_group/screens/asset_details_page.dart';
import 'package:flutter_assignment_group/screens/dashboard_page.dart';
import 'package:flutter_assignment_group/screens/edit_asset_page.dart';
import 'package:flutter_assignment_group/screens/login_page.dart';

class AssetTrackApp extends StatefulWidget {
  const AssetTrackApp({super.key});

  @override
  State<AssetTrackApp> createState() => _AssetTrackAppState();
}

enum _AppPage { login, dashboard, details, addAsset, editAsset }

class _AssetTrackAppState extends State<AssetTrackApp> {
  _AppPage _currentPage = _AppPage.login;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _buildCurrentPage(),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case _AppPage.login:
        return LoginPage(
          key: const ValueKey('login_page'),
          onLogin: () => setState(() => _currentPage = _AppPage.dashboard),
        );
      case _AppPage.dashboard:
        return DashboardPage(
          key: const ValueKey('dashboard_page'),
          onOpenDetail: () => setState(() => _currentPage = _AppPage.details),
          onAddAsset: () => setState(() => _currentPage = _AppPage.addAsset),
        );
      case _AppPage.details:
        return AssetDetailsPage(
          key: const ValueKey('details_page'),
          onBack: () => setState(() => _currentPage = _AppPage.dashboard),
          onEdit: () => setState(() => _currentPage = _AppPage.editAsset),
        );
      case _AppPage.addAsset:
        return AddAssetPage(
          key: const ValueKey('add_asset_page'),
          onBack: () => setState(() => _currentPage = _AppPage.dashboard),
        );
      case _AppPage.editAsset:
        return EditAssetPage(
          key: const ValueKey('edit_asset_page'),
          onBack: () => setState(() => _currentPage = _AppPage.details),
        );
    }
  }
}

