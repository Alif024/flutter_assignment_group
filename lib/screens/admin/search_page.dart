import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/cards/recent_activity_card.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.repository,
    required this.onOpenDetail,
    required this.onOpenDashboard,
    required this.onAddAsset,
    required this.onOpenProfile,
  });

  final FirestoreRepository repository;
  final ValueChanged<String> onOpenDetail;
  final VoidCallback onOpenDashboard;
  final VoidCallback onAddAsset;
  final VoidCallback onOpenProfile;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetRecord>>(
      stream: widget.repository.watchAssets(),
      builder: (context, snapshot) {
        final assets = snapshot.data ?? const <AssetRecord>[];
        final results = _applyFilter(assets);

        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          appBar: AppTopBar(
            title: 'Search Assets',
            showBack: false,
            action: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: Column(
                children: [
                  _SearchField(
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 12),
                  _StatusChips(
                    value: _statusFilter,
                    onChanged: (value) => setState(() => _statusFilter = value),
                  ),
                  const SizedBox(height: 12),
                  SurfaceCard(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Results: ${results.length}/${assets.length}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: results.isEmpty
                        ? const Center(
                            child: Text(
                              'No assets found.',
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
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 1,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            onTap: (index) {
              if (index == 0) {
                widget.onOpenDashboard();
              } else if (index == 2) {
                widget.onAddAsset();
              } else if (index == 3) {
                widget.onOpenProfile();
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
  }

  List<AssetRecord> _applyFilter(List<AssetRecord> assets) {
    final normalized = _query.trim().toLowerCase();
    return assets.where((asset) {
      final matchStatus = _statusFilter == 'all'
          ? true
          : asset.status == _statusFilter;

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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

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

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.value, required this.onChanged});

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
