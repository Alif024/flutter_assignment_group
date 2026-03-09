import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/components/layout/asset_detail_row.dart';
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
            backgroundColor: const Color(0xFFE5E7EB),
            appBar: AppTopBar(title: 'Asset Details', onBack: onBack),
            body: const Center(child: Text('Asset not found.')),
            bottomNavigationBar: UserBottomNav(
              currentIndex: 0,
              onTapRepairs: onOpenRepairsTab,
              onTapScan: onOpenScanTab,
              onTapProfile: onOpenProfileTab,
            ),
          );
        }

        final displayImageUrl = _resolveAssetImageUrl(asset.imageUrl);

        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          appBar: AppTopBar(title: 'Asset Details', onBack: onBack),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildAssetImage(displayImageUrl),
                  ),
                  const SizedBox(height: 16),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asset.name,
                                    style: const TextStyle(
                                      fontSize: 56 / 1.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    asset.assetCode,
                                    style: const TextStyle(
                                      fontSize: 18 / 1.5,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _statusLabel(asset.status),
                              style: TextStyle(
                                color: _statusColor(asset.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 36 / 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AssetDetailRow(
                          icon: _iconForType(asset.type),
                          label: 'Asset Type',
                          value: asset.type,
                        ),
                        const SizedBox(height: 12),
                        AssetDetailRow(
                          icon: Icons.sell,
                          label: 'Brand',
                          value: asset.brand,
                        ),
                        const SizedBox(height: 12),
                        AssetDetailRow(
                          icon: Icons.format_list_bulleted,
                          label: 'Description',
                          value: asset.description.isEmpty
                              ? '-'
                              : asset.description,
                        ),
                        const SizedBox(height: 12),
                        AssetDetailRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: asset.location,
                        ),
                        const SizedBox(height: 12),
                        AssetDetailRow(
                          icon: Icons.calendar_month,
                          label: 'Purchase Date',
                          value: asset.purchaseDate == null
                              ? '-'
                              : _formatDate(asset.purchaseDate!),
                        ),
                        const SizedBox(height: 12),
                        AssetDetailRow(
                          icon: Icons.check_circle,
                          label: 'Current Status',
                          value: _statusLabel(asset.status),
                          valueColor: _statusColor(asset.status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'under_repair':
        return const Color(0xFFDC2626);
      case 'disposed':
        return const Color(0xFF7C3AED);
      case 'normal':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF334155);
    }
  }

  IconData _iconForType(String type) {
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

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String _resolveAssetImageUrl(String rawUrl) {
    const fallbackUrl =
        'https://images.unsplash.com/photo-1593642634367-d91a135587b5?w=1200';

    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return fallbackUrl;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return fallbackUrl;
    }

    final host = uri.host.toLowerCase();
    if (!host.contains('drive.google.com')) {
      return trimmed;
    }

    final fileId = _extractGoogleDriveFileId(uri);
    if (fileId == null || fileId.isEmpty) {
      return trimmed;
    }

    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }

  Widget _buildAssetImage(String imageUrl) {
    final uri = Uri.tryParse(imageUrl);
    final isNetwork = uri != null &&
        (uri.scheme.toLowerCase() == 'http' || uri.scheme.toLowerCase() == 'https');

    if (isNetwork) {
      return Image.network(
        imageUrl,
        height: 280,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }

    final file = File(imageUrl);
    if (!file.existsSync()) {
      return _buildImageFallback();
    }

    return Image.file(
      file,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 280,
      color: const Color(0xFFD1D5DB),
      alignment: Alignment.center,
      child: const Icon(Icons.laptop_mac, size: 56),
    );
  }

  String? _extractGoogleDriveFileId(Uri uri) {
    final idFromQuery = uri.queryParameters['id'];
    if (idFromQuery != null && idFromQuery.trim().isNotEmpty) {
      return idFromQuery.trim();
    }

    final segments = uri.pathSegments;
    final fileSegmentIndex = segments.indexOf('d');
    if (fileSegmentIndex != -1 && fileSegmentIndex + 1 < segments.length) {
      return segments[fileSegmentIndex + 1].trim();
    }

    return null;
  }
}
