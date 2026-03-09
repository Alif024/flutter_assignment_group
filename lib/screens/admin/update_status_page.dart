import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';

class AdminUpdateStatusPage extends StatefulWidget {
  const AdminUpdateStatusPage({
    super.key,
    required this.repository,
    required this.assetCode,
    required this.currentStatus,
    required this.actorEmployeeId,
  });

  final FirestoreRepository repository;
  final String assetCode;
  final String currentStatus;
  final String actorEmployeeId;

  @override
  State<AdminUpdateStatusPage> createState() => _AdminUpdateStatusPageState();
}

class _AdminUpdateStatusPageState extends State<AdminUpdateStatusPage> {
  final TextEditingController _noteController = TextEditingController();
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.repository.updateAssetStatus(
        assetCode: widget.assetCode,
        status: _selectedStatus,
        note: _noteController.text.trim(),
        actorEmployeeId: widget.actorEmployeeId,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(title: 'Update Status'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            children: [
              _StatusOptionTile(
                title: 'Normal',
                description: 'Asset is functioning properly',
                icon: Icons.check_circle,
                iconColor: const Color(0xFF16A34A),
                selected: _selectedStatus == 'normal',
                onTap: () => setState(() => _selectedStatus = 'normal'),
              ),
              const SizedBox(height: 10),
              _StatusOptionTile(
                title: 'Under Repair',
                description: 'Asset is currently being serviced',
                icon: Icons.build,
                iconColor: const Color(0xFF2563EB),
                selected: _selectedStatus == 'under_repair',
                onTap: () => setState(() => _selectedStatus = 'under_repair'),
              ),
              const SizedBox(height: 10),
              _StatusOptionTile(
                title: 'Disposed',
                description: 'Asset has been removed from inventory',
                icon: Icons.delete,
                iconColor: const Color(0xFFDC2626),
                selected: _selectedStatus == 'disposed',
                onTap: () => setState(() => _selectedStatus = 'disposed'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _noteController,
                maxLength: 200,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add details for this status update...',
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _confirm,
                      child: Text(_isSubmitting ? 'Saving...' : 'Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
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
