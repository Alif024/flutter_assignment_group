import 'package:flutter/material.dart';

class UserBottomNav extends StatelessWidget {
  const UserBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTapRepairs,
    required this.onTapScan,
    required this.onTapProfile,
  });

  final int currentIndex;
  final VoidCallback? onTapRepairs;
  final VoidCallback? onTapScan;
  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          onTapRepairs?.call();
        } else if (index == 1) {
          onTapScan?.call();
        } else if (index == 2) {
          onTapProfile?.call();
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_outlined),
          label: 'Repairs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
