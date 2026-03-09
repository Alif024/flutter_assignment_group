import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/screens/admin/add_asset_page.dart';
import 'package:flutter_assignment_group/screens/admin/asset_details_page.dart';
import 'package:flutter_assignment_group/screens/admin/dashboard_page.dart';
import 'package:flutter_assignment_group/screens/admin/edit_asset_page.dart';
import 'package:flutter_assignment_group/screens/admin/scan_qr_page.dart';
import 'package:flutter_assignment_group/screens/admin/search_page.dart';
import 'package:flutter_assignment_group/screens/login_page.dart';
import 'package:flutter_assignment_group/screens/profile_page.dart';
import 'package:flutter_assignment_group/user/asset_track_app.dart';

class AssetTrackApp extends StatelessWidget {
  const AssetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE5E7EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D66DF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D66DF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2D66DF),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2D66DF),
          ),
        ),
      ),
      home: _AssetTrackShell(),
    );
  }
}

enum _AppPage {
  login,
  userShell,
  dashboard,
  details,
  addAsset,
  editAsset,
  scanQr,
  search,
  profile,
}

class _AssetTrackShell extends StatefulWidget {
  const _AssetTrackShell();

  @override
  State<_AssetTrackShell> createState() => _AssetTrackShellState();
}

class _AssetTrackShellState extends State<_AssetTrackShell> {
  final FirestoreRepository _repository = FirestoreRepository();
  _AppPage _currentPage = _AppPage.login;
  String? _selectedAssetCode;
  String _currentEmployeeId = 'EMP-1908';

  Future<void> _navigateToPage(
    _AppPage page, {
    String? selectedAssetCode,
    bool clearSelectedAssetCode = false,
  }) async {
    final focus = FocusManager.instance.primaryFocus;
    final wasKeyboardVisible =
        (MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0) > 0;

    focus?.unfocus();

    // Give IME insets time to settle before replacing the entire page subtree.
    await Future<void>.delayed(
      wasKeyboardVisible
          ? const Duration(milliseconds: 250)
          : const Duration(milliseconds: 16),
    );

    if (!mounted) {
      return;
    }

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

  Future<void> _openAssetFromScanOrInput(String assetCode) async {
    final normalizedCode = assetCode.trim();
    if (normalizedCode.isEmpty) {
      return;
    }

    final asset = await _repository.getAsset(normalizedCode);
    if (!mounted) {
      return;
    }

    if (asset != null) {
      await _navigateToPage(
        _AppPage.details,
        selectedAssetCode: normalizedCode,
      );
      return;
    }

    await _navigateToPage(
      _AppPage.addAsset,
      selectedAssetCode: normalizedCode,
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case _AppPage.login:
        return LoginPage(
          key: const ValueKey('login_page'),
          onLogin: (username, password) async {
            final user = await _repository.authenticateUser(
              username: username,
              password: password,
            );
            if (!mounted) {
              return;
            }
            _currentEmployeeId = user.employeeId;
            if (_currentEmployeeId == 'EMP-1909') {
              await _navigateToPage(
                _AppPage.userShell,
                clearSelectedAssetCode: true,
              );
              return;
            }
            await _navigateToPage(
              _AppPage.dashboard,
              clearSelectedAssetCode: true,
            );
          },
        );
      case _AppPage.userShell:
        return UserAssetTrackShell(
          key: const ValueKey('user_shell_page'),
          repository: _repository,
          employeeId: _currentEmployeeId,
          onLogout: () =>
              _navigateToPage(_AppPage.login, clearSelectedAssetCode: true),
        );
      case _AppPage.dashboard:
        return _buildDashboardPage();
      case _AppPage.details:
        final selectedAssetCode = _selectedAssetCode;
        if (selectedAssetCode == null) {
          return _buildDashboardPage();
        }
        return AssetDetailsPage(
          key: const ValueKey('details_page'),
          repository: _repository,
          assetCode: selectedAssetCode,
          onBack: () => _navigateToPage(_AppPage.dashboard),
          onEdit: (assetCode) => _navigateToPage(
            _AppPage.editAsset,
            selectedAssetCode: assetCode,
          ),
          onDeleted: () =>
              _navigateToPage(_AppPage.dashboard, clearSelectedAssetCode: true),
          actorEmployeeId: _currentEmployeeId,
        );
      case _AppPage.addAsset:
        final selectedAssetCode = _selectedAssetCode;
        return AddAssetPage(
          key: const ValueKey('add_asset_page'),
          repository: _repository,
          onBack: () => _navigateToPage(_AppPage.dashboard),
          actorEmployeeId: _currentEmployeeId,
          initialAssetCode: selectedAssetCode,
          onSaved: (assetCode) =>
              _navigateToPage(_AppPage.details, selectedAssetCode: assetCode),
        );
      case _AppPage.editAsset:
        final selectedAssetCode = _selectedAssetCode;
        if (selectedAssetCode == null) {
          return _buildDashboardPage();
        }
        return EditAssetPage(
          key: const ValueKey('edit_asset_page'),
          repository: _repository,
          assetCode: selectedAssetCode,
          onBack: () => _navigateToPage(_AppPage.details),
          actorEmployeeId: _currentEmployeeId,
          onSaved: (assetCode) =>
              _navigateToPage(_AppPage.details, selectedAssetCode: assetCode),
        );
      case _AppPage.scanQr:
        return ScanQrPage(
          key: const ValueKey('scan_qr_page'),
          onBack: () => _navigateToPage(_AppPage.dashboard),
          onOpenAsset: (assetCode) {
            _openAssetFromScanOrInput(assetCode);
          },
        );
      case _AppPage.search:
        return SearchPage(
          key: const ValueKey('search_page'),
          repository: _repository,
          onOpenDetail: (assetCode) =>
              _navigateToPage(_AppPage.details, selectedAssetCode: assetCode),
          onOpenDashboard: () => _navigateToPage(_AppPage.dashboard),
          onAddAsset: () =>
              _navigateToPage(_AppPage.addAsset, clearSelectedAssetCode: true),
          onOpenProfile: () => _navigateToPage(_AppPage.profile),
        );
      case _AppPage.profile:
        return ProfilePage(
          key: const ValueKey('profile_page'),
          repository: _repository,
          employeeId: _currentEmployeeId,
          onOpenDashboard: () => _navigateToPage(_AppPage.dashboard),
          onOpenSearch: () => _navigateToPage(_AppPage.search),
          onAddAsset: () =>
              _navigateToPage(_AppPage.addAsset, clearSelectedAssetCode: true),
          onLogout: () =>
              _navigateToPage(_AppPage.login, clearSelectedAssetCode: true),
        );
    }
  }

  Widget _buildDashboardPage() {
    return DashboardPage(
      key: const ValueKey('dashboard_page'),
      repository: _repository,
      employeeId: _currentEmployeeId,
      onOpenDetail: (assetCode) {
        _navigateToPage(_AppPage.details, selectedAssetCode: assetCode);
      },
      onAddAsset: () =>
          _navigateToPage(_AppPage.addAsset, clearSelectedAssetCode: true),
      onScanQr: () => _navigateToPage(_AppPage.scanQr),
      onOpenSearch: () => _navigateToPage(_AppPage.search),
      onOpenProfile: () => _navigateToPage(_AppPage.profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCurrentPage();
  }
}
