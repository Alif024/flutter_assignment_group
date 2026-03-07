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

  Future<void> _showUpdateStatusDialog(BuildContext context) async {
    final noteController = TextEditingController();
    var selectedStatus = _AssetStatus.normal;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final noteLength = noteController.text.length;

              return Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Update Status',
                              style: TextStyle(
                                fontSize: 30 / 1.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF64748B),
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Change the current status of this asset',
                        style: TextStyle(
                          fontSize: 22 / 1.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _StatusOptionTile(
                        title: 'Normal',
                        description: 'Asset is functioning properly',
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFF16A34A),
                        selected: selectedStatus == _AssetStatus.normal,
                        onTap: () {
                          setState(() {
                            selectedStatus = _AssetStatus.normal;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _StatusOptionTile(
                        title: 'Under Repair',
                        description: 'Asset is currently being serviced',
                        icon: Icons.build,
                        iconColor: const Color(0xFF2563EB),
                        selected: selectedStatus == _AssetStatus.underRepair,
                        onTap: () {
                          setState(() {
                            selectedStatus = _AssetStatus.underRepair;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _StatusOptionTile(
                        title: 'Disposed',
                        description: 'Asset has been removed from inventory',
                        icon: Icons.delete,
                        iconColor: const Color(0xFFDC2626),
                        selected: selectedStatus == _AssetStatus.disposed,
                        onTap: () {
                          setState(() {
                            selectedStatus = _AssetStatus.disposed;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontSize: 24 / 1.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLength: 200,
                        minLines: 3,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'Add any additional information about this status change...',
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Max $noteLength/200 characters',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF111827),
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Confirm Update',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      noteController.dispose();
    }
  }

  Future<void> _showDeleteSuccessDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF0000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(239, 68, 68, 0.35),
                        offset: Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deleted Successfully',
                  style: TextStyle(
                    fontSize: 34 / 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your item has been permanently removed\nand cannot be recovered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21 / 1.5,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF374151),
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              FilledBtnIcon(
                text: 'Update Status',
                icon: Icons.autorenew,
                color: FilledBtnColor.gray,
                onPressed: () => _showUpdateStatusDialog(context),
              ),
              const SizedBox(height: 12),
              OutlinedBtnIcon(
                text: 'Delete Asset',
                icon: Icons.delete,
                fontColor: OutlinedBtnFontColor.red,
                onPressed: () => _showDeleteSuccessDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AssetStatus { normal, underRepair, disposed }

class _StatusOptionTile extends StatelessWidget {
  const _StatusOptionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Center(
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF2563EB),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: iconColor),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 23 / 1.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 20 / 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
