import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
    this.action,
    this.height = 104,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? action;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2D66DF),
      elevation: 0,
      centerTitle: true,
      toolbarHeight: height,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 35 / 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (action != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: action,
          )
        else
          const SizedBox(width: 44),
      ],
    );
  }
}

