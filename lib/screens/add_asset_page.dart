import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/cards/upload_img_card.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';

class AddAssetPage extends StatefulWidget {
  const AddAssetPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final TextEditingController _assetIdController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _assetIdController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
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
                    const Text(
                      'Asset Image',
                      style: TextStyle(
                        fontSize: 20 / 1.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    UploadImgCard(
                      height: 200,
                      title: 'Tap to upload image',
                      subtitle: 'JPG, PNG or JPEG (max. 5MB)',
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
              const SurfaceCard(
                child: _SelectBox(label: 'Asset Type', hint: 'Select Type'),
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
                text: 'Save Asset',
                icon: Icons.save,
                onPressed: () {},
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

class _SelectBox extends StatelessWidget {
  const _SelectBox({required this.label, required this.hint});

  final String label;
  final String hint;

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
          child: Row(
            children: [
              Text(
                hint,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 20),
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ],
    );
  }
}

