import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/cards/upload_img_card.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:image_picker/image_picker.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({
    super.key,
    required this.repository,
    required this.actorEmployeeId,
    required this.onBack,
    required this.onSaved,
    this.initialAssetCode,
  });

  final FirestoreRepository repository;
  final String actorEmployeeId;
  final VoidCallback onBack;
  final ValueChanged<String> onSaved;
  final String? initialAssetCode;

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final UploadImgCardController _uploadImgController = UploadImgCardController();
  final TextEditingController _assetIdController = TextEditingController();
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> _assetTypes = const [
    'laptop',
    'printer',
    'chair',
    'other',
  ];

  String _selectedType = 'laptop';
  String _selectedImageUrl = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialCode = widget.initialAssetCode?.trim() ?? '';
    if (initialCode.isNotEmpty) {
      _assetIdController.text = initialCode;
    }
  }

  @override
  void dispose() {
    _assetIdController.dispose();
    _assetNameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveAsset() async {
    final assetId = _assetIdController.text.trim();
    final assetName = _assetNameController.text.trim();
    final brand = _brandController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (assetId.isEmpty || assetName.isEmpty) {
      _showMessage('Please fill in Asset ID and Asset Name.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      await widget.repository.addAsset(
        AssetRecord(
          assetCode: assetId,
          name: assetName,
          type: _selectedType,
          brand: brand.isEmpty ? 'N/A' : brand,
          description: description,
          location: location.isEmpty ? 'Unknown Location' : location,
          status: 'normal',
          imageUrl: _selectedImageUrl,
          purchaseDate: now,
          assignedTo: widget.actorEmployeeId,
          createdAt: now,
          updatedAt: now,
        ),
        actorEmployeeId: widget.actorEmployeeId,
      );

      if (!mounted) {
        return;
      }
      widget.onSaved(assetId);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleImageSelected(XFile? file) {
    setState(() {
      _selectedImageUrl = file?.path.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppTopBar(title: 'Add Asset', onBack: widget.onBack),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Column(
            children: [
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Asset Image',
                            style: TextStyle(
                              fontSize: 20 / 1.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Take photo',
                          onPressed: () {
                            _uploadImgController.pickFromCamera();
                          },
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    UploadImgCard(
                      controller: _uploadImgController,
                      height: 200,
                      title: 'Tap to upload image',
                      subtitle: 'JPG, PNG or JPEG (max. 5MB)',
                      onImageSelected: _handleImageSelected,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: InputTextIcon(
                  controller: _assetIdController,
                  label: 'Asset ID',
                  hintText: 'Enter Asset ID',
                  icon: Icons.tag,
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: InputTextIcon(
                  controller: _assetNameController,
                  label: 'Asset Name',
                  hintText: 'Enter Asset Name',
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: _AssetTypeSelector(
                  value: _selectedType,
                  options: _assetTypes,
                  onChanged: (value) => setState(() => _selectedType = value),
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: InputTextIcon(
                  controller: _brandController,
                  label: 'Brand',
                  hintText: 'Enter Brand Name',
                  icon: Icons.sell,
                ),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: _DescriptionField(controller: _descriptionController),
              ),
              const SizedBox(height: 14),
              SurfaceCard(
                child: InputTextIcon(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'e.g., Floor 3, Room 305',
                  icon: Icons.location_on,
                ),
              ),
              const SizedBox(height: 16),
              FilledBtnIcon(
                text: _isSaving ? 'Saving...' : 'Save Asset',
                icon: Icons.save,
                onPressed: _isSaving ? null : _saveAsset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          minLines: 3,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter detailed description of the asset...',
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 56),
              child: Icon(Icons.format_list_bulleted),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD6DAE1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD6DAE1)),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssetTypeSelector extends StatelessWidget {
  const _AssetTypeSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asset Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6DAE1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
