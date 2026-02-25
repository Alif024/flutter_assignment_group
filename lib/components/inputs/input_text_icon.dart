import 'package:flutter/material.dart';

enum InputIconPosition { left, right }

class InputTextIcon extends StatefulWidget {
  const InputTextIcon({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.iconPosition = InputIconPosition.left,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final InputIconPosition iconPosition;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<InputTextIcon> createState() => _InputTextIconState();
}

class _InputTextIconState extends State<InputTextIcon> {
  late final FocusNode _focusNode;

  bool get _isActive =>
      _focusNode.hasFocus || widget.controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_refreshState);
    widget.controller.addListener(_refreshState);
  }

  @override
  void didUpdateWidget(covariant InputTextIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refreshState);
      widget.controller.addListener(_refreshState);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_refreshState);
    _focusNode.dispose();
    widget.controller.removeListener(_refreshState);
    super.dispose();
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isActive
        ? const Color(0xFF151C33)
        : const Color(0xFF9AA1B2);

    final decoration = InputDecoration(
      hintText: widget.hintText,
      filled: true,
      fillColor: const Color(0xFFF7F7F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DAE1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6DAE1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6C87FF), width: 1.3),
      ),
      prefixIcon: widget.iconPosition == InputIconPosition.left
          ? Icon(widget.icon, color: iconColor)
          : null,
      suffixIcon: widget.iconPosition == InputIconPosition.right
          ? Icon(widget.icon, color: iconColor)
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF151C33),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          decoration: decoration,
        ),
      ],
    );
  }
}
