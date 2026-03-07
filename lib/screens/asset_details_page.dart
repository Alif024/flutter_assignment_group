import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/buttons/outlined_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/components/layout/asset_detail_row.dart';

class AssetDetailsPage extends StatelessWidget {
  const AssetDetailsPage({
    super.key,
    required this.onBack,
    required this.onEdit,
  });

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(
        title: 'Asset Details',
        onBack: onBack,
        action: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1593642634367-d91a135587b5?w=1200',
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 280,
                    color: const Color(0xFFD1D5DB),
                    alignment: Alignment.center,
                    child: const Icon(Icons.laptop_mac, size: 56),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SurfaceCard(
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
                                'Dell Latitude 5420',
                                style: TextStyle(
                                  fontSize: 56 / 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'AST-2024-0156',
                                style: TextStyle(
                                  fontSize: 18 / 1.5,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Normal',
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                            fontSize: 36 / 1.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    AssetDetailRow(
                      icon: Icons.laptop,
                      label: 'Asset Type',
                      value: 'Laptop',
                    ),
                    SizedBox(height: 12),
                    AssetDetailRow(
                      icon: Icons.sell,
                      label: 'Brand',
                      value: 'Dell',
                    ),
                    SizedBox(height: 12),
                    AssetDetailRow(
                      icon: Icons.format_list_bulleted,
                      label: 'Description',
                      value:
                          '14-inch business laptop with Intel\nCore i5 processor, 16GB RAM,\n512GB SSD. Features include\nbacklit keyboard, fingerprint\nreader, and Windows 11 Pro.',
                    ),
                    SizedBox(height: 12),
                    AssetDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: 'Floor 3, Room 305',
                    ),
                    SizedBox(height: 12),
                    AssetDetailRow(
                      icon: Icons.calendar_month,
                      label: 'Purchase Date',
                      value: 'January 15, 2024',
                    ),
                    SizedBox(height: 12),
                    AssetDetailRow(
                      icon: Icons.check_circle,
                      label: 'Current Status',
                      value: 'Normal - In Use',
                      valueColor: Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledBtnIcon(
                text: 'Edit Details',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              const SizedBox(height: 12),
              const FilledBtnIcon(
                text: 'Update Status',
                icon: Icons.autorenew,
                color: FilledBtnColor.gray,
                onPressed: null,
              ),
              const SizedBox(height: 12),
              const OutlinedBtnIcon(
                text: 'Delete Asset',
                icon: Icons.delete,
                fontColor: OutlinedBtnFontColor.red,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

