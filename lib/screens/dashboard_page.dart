import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/buttons/outlined_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/dashboard_stat_card.dart';
import 'package:flutter_assignment_group/components/cards/recent_activity_card.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_activity_record.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:flutter_assignment_group/models/user_profile_record.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.repository,
    required this.employeeId,
    required this.onOpenDetail,
    required this.onAddAsset,
    required this.onScanQr,
    required this.onOpenProfile,
    required this.onOpenSearch,
  });

  final FirestoreRepository repository;
  final String employeeId;
  final ValueChanged<String> onOpenDetail;
  final VoidCallback onAddAsset;
  final VoidCallback onScanQr;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSearch;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetRecord>>(
      stream: widget.repository.watchAssets(),
      builder: (context, assetsSnapshot) {
        final assets = assetsSnapshot.data ?? const <AssetRecord>[];
        final filteredAssets = _filterAssets(assets, _searchText);
        final normalCount = assets
            .where((asset) => asset.status == 'normal')
            .length;
        final underRepairCount = assets
            .where((asset) => asset.status == 'under_repair')
            .length;

        return StreamBuilder<UserProfileRecord?>(
          stream: widget.repository.watchUserProfile(widget.employeeId),
          builder: (context, userSnapshot) {
            final user = userSnapshot.data;
            final displayName = user?.name.trim().isNotEmpty == true
                ? user!.name
                : widget.employeeId;
            final displayRole = _formatRole(user?.role ?? 'Inventory Officer');
            final photoUrl = user?.photoUrl ?? '';

            return Scaffold(
              backgroundColor: const Color(0xFFE5E7EB),
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(
                      displayName: displayName,
                      displayRole: displayRole,
                      photoUrl: photoUrl,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTotalAssetsCard(assets.length),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 168,
                                    child: DashboardStatCard(
                                      label: 'Normal',
                                      value: normalCount.toString(),
                                      icon: Icons.check_circle,
                                      iconColor: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 168,
                                    child: DashboardStatCard(
                                      label: 'Under Repair',
                                      value: underRepairCount.toString(),
                                      icon: Icons.handyman,
                                      iconColor: const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 44 / 1.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledBtnIcon(
                              text: 'Scan QR Code',
                              onPressed: widget.onScanQr,
                              icon: Icons.qr_code_scanner,
                            ),
                            const SizedBox(height: 12),
                            OutlinedBtnIcon(
                              text: 'Search Asset',
                              icon: Icons.search,
                              onPressed: widget.onOpenSearch,
                            ),
                            const SizedBox(height: 12),
                            FilledBtnIcon(
                              text: 'Add New Asset',
                              icon: Icons.add,
                              color: FilledBtnColor.green,
                              onPressed: widget.onAddAsset,
                            ),
                            const SizedBox(height: 26),
                            _buildRecentActivitySection(
                              assets: assets,
                              filteredAssets: filteredAssets,
                            ),
                            const SizedBox(height: 20),
                            _buildLatestAssetsSection(filteredAssets),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black,
                onTap: (index) {
                  if (index == 2) {
                    widget.onAddAsset();
                  } else if (index == 1) {
                    widget.onOpenSearch();
                  } else if (index == 3) {
                    widget.onOpenProfile();
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader({
    required String displayName,
    required String displayRole,
    required String photoUrl,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2D66DF),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: const Color(0x3322293B),
                ),
                child: ClipOval(
                  child: photoUrl.trim().isNotEmpty
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                            );
                          },
                        )
                      : const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40 / 1.5,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      displayRole,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchText = value),
                    textInputAction: TextInputAction.search,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(
                      hintText: 'Search assets...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    if (!role.contains('_')) {
      return role;
    }
    return role
        .split('_')
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }

  Widget _buildTotalAssetsCard(int totalAssets) {
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Assets',
                  style: TextStyle(
                    fontSize: 20 / 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  totalAssets.toString(),
                  style: const TextStyle(
                    fontSize: 62 / 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.widgets_rounded, color: Color(0xFF2D66DF), size: 36),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection({
    required List<AssetRecord> assets,
    required List<AssetRecord> filteredAssets,
  }) {
    final assetsById = <String, AssetRecord>{
      for (final asset in assets) asset.assetCode: asset,
    };

    return StreamBuilder<List<AssetActivityRecord>>(
      stream: widget.repository.watchRecentActivities(limit: 3),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? const <AssetActivityRecord>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 44 / 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: filteredAssets.isEmpty
                      ? null
                      : () =>
                            widget.onOpenDetail(filteredAssets.first.assetCode),
                  child: const Text('View All'),
                ),
              ],
            ),
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No recent activity found.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ...activities.map((activity) {
              final asset = assetsById[activity.assetId];
              final status = _labelForStatus(activity.toStatus);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RecentActivityCard(
                  title: asset?.name.isNotEmpty == true
                      ? asset!.name
                      : activity.assetId,
                  activityText: _labelForAction(activity.action),
                  timeText: _relativeTime(activity.createdAt),
                  statusText: status,
                  icon: _iconForType(asset?.type),
                  statusColor: _colorForStatus(activity.toStatus),
                  iconColor: _colorForStatus(activity.toStatus),
                  onTap: () => widget.onOpenDetail(activity.assetId),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildLatestAssetsSection(List<AssetRecord> filteredAssets) {
    final displayAssets = filteredAssets.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Assets',
          style: TextStyle(fontSize: 44 / 1.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (displayAssets.isEmpty)
          const Text(
            'No assets found.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ...displayAssets.map((asset) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecentActivityCard(
              title: asset.name,
              activityText: asset.brand,
              timeText: asset.assetCode,
              statusText: _labelForStatus(asset.status),
              icon: _iconForType(asset.type),
              statusColor: _colorForStatus(asset.status),
              iconColor: _colorForStatus(asset.status),
              onTap: () => widget.onOpenDetail(asset.assetCode),
            ),
          );
        }),
      ],
    );
  }

  List<AssetRecord> _filterAssets(List<AssetRecord> assets, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return assets;
    }

    return assets.where((asset) {
      return asset.assetCode.toLowerCase().contains(normalized) ||
          asset.name.toLowerCase().contains(normalized) ||
          asset.brand.toLowerCase().contains(normalized) ||
          asset.status.toLowerCase().contains(normalized);
    }).toList();
  }

  String _labelForStatus(String status) {
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

  String _labelForAction(String action) {
    switch (action) {
      case 'added':
        return 'Added';
      case 'deleted':
        return 'Deleted';
      case 'status_updated':
        return 'Status updated';
      case 'details_updated':
        return 'Details updated';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  Color _colorForStatus(String status) {
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

  IconData _iconForType(String? type) {
    switch (type) {
      case 'Laptop':
      case 'laptop':
        return Icons.laptop;
      case 'Printer':
      case 'printer':
        return Icons.print;
      case 'Office Chair':
      case 'chair':
        return Icons.chair;
      default:
        return Icons.widgets;
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }
}
