import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';

class EditAssetPage extends StatefulWidget {
  const EditAssetPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<EditAssetPage> createState() => _EditAssetPageState();
}

class _EditAssetPageState extends State<EditAssetPage> {
  final TextEditingController _assetIdController = TextEditingController(
    text: 'AST-2024-0156',
  );
  final TextEditingController _brandController = TextEditingController(
    text: 'DELL',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text:
        '14-inch business laptop with Intel\nCore i5 processor, 16GB RAM,\n512GB SSD. Features include\nbacklit keyboard, fingerprint\nreader, and Windows 11 Pro.',
  );
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
                    const Text(
                      'Asset Image',
                      style: TextStyle(
                        fontSize: 20 / 1.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1593642634367-d91a135587b5?w=1200',
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 220,
                          color: const Color(0xFFD1D5DB),
                          alignment: Alignment.center,
                          child: const Icon(Icons.laptop_mac, size: 56),
                        ),
                      ),
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

