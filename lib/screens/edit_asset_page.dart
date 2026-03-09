import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/cards/upload_img_card.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/asset_record.dart';
import 'package:image_picker/image_picker.dart';

class EditAssetPage extends StatefulWidget {
  const EditAssetPage({
    super.key,
    required this.repository,
    required this.assetCode,
    required this.actorEmployeeId,
    required this.onBack,
    required this.onSaved,
  });

  final FirestoreRepository repository;
  final String assetCode;
  final String actorEmployeeId;
  final VoidCallback onBack;
  final ValueChanged<String> onSaved;

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  final UploadImgCardController _uploadImgController = UploadImgCardController();
  final TextEditingController _nameController = TextEditingController();
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
  String _status = 'normal';
  String _imageUrl = '';
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _fillInitialValue(AssetRecord asset) {
    if (_initialized) {
      return;
    }
    _nameController.text = asset.name;
    _brandController.text = asset.brand;
    _descriptionController.text = asset.description;
    _locationController.text = asset.location;
    _selectedType = asset.type.isEmpty ? 'other' : asset.type;
    _status = asset.status;
    _imageUrl = asset.imageUrl.trim();
    _initialized = true;
  }

  void _handleImageSelected(XFile? file) {
    setState(() {
      _imageUrl = file?.path.trim() ?? _imageUrl;
    });
  }

  Future<void> _saveAsset(AssetRecord current) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('Asset Name is required.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.repository.updateAsset(
        current.copyWith(
          name: name,
          brand: _brandController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          type: _selectedType,
          status: _status,
          imageUrl: _imageUrl,
        ),
        actorEmployeeId: widget.actorEmployeeId,
      );

      if (!mounted) {
        return;
      }
      widget.onSaved(widget.assetCode);
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AssetRecord?>(
      stream: widget.repository.watchAsset(widget.assetCode),
      builder: (context, snapshot) {
        final asset = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting &&
            asset == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (asset == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFE5E7EB),
            appBar: AppTopBar(title: 'Edit Asset', onBack: widget.onBack),
            body: const Center(child: Text('Asset not found.')),
          );
        }

        _fillInitialValue(asset);

        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          appBar: AppTopBar(title: 'Edit Asset', onBack: widget.onBack),
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
                          height: 220,
                          title: 'Tap to upload image',
                          subtitle: 'JPG, PNG or JPEG (max. 5MB)',
                          initialImageUrl: _imageUrl,
                          onImageSelected: _handleImageSelected,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ReadOnlyField(label: 'Asset ID', value: asset.assetCode),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    child: InputTextIcon(
                      controller: _nameController,
                      label: 'Asset Name',
                      hintText: 'Enter Asset Name',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    child: _SelectBox(
                      label: 'Asset Type',
                      value: _selectedType,
                      options: _assetTypes,
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
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
                    child: _DescriptionField(
                      controller: _descriptionController,
                    ),
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
                  const SizedBox(height: 14),
                  SurfaceCard(
                    child: _SelectBox(
                      label: 'Status',
                      value: _status,
                      options: const ['normal', 'under_repair', 'disposed'],
                      onChanged: (value) => setState(() => _status = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledBtnIcon(
                    text: _isSaving ? 'Saving...' : 'Save Asset',
                    icon: Icons.save,
                    onPressed: _isSaving ? null : () => _saveAsset(asset),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 92),
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

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              items: options
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
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

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 56,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD6DAE1)),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}
