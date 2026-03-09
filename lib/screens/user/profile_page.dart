import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/layout/app_top_bar.dart';
import 'package:flutter_assignment_group/data/firestore_repository.dart';
import 'package:flutter_assignment_group/models/user_profile_record.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    required this.repository,
    required this.employeeId,
    required this.onOpenRepairs,
    required this.onOpenScan,
    required this.onLogout,
  });

  final FirestoreRepository repository;
  final String employeeId;
  final VoidCallback onOpenRepairs;
  final VoidCallback onOpenScan;
  final VoidCallback onLogout;

  Future<void> _showEditProfileDialog(
    BuildContext context,
    UserProfileRecord user,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _EditProfileDialog(
        repository: repository,
        user: user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfileRecord?>(
      stream: repository.watchUserProfile(employeeId),
      builder: (context, userSnapshot) {
        final user =
            userSnapshot.data ??
            UserProfileRecord(
              employeeId: employeeId,
              username: employeeId,
              password: '123456',
              name: 'Employee $employeeId',
              email: '',
              role: 'Inventory Officer',
              phone: '-',
              office: '-',
              photoUrl: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

        return Scaffold(
                  backgroundColor: const Color(0xFFE5E7EB),
                  appBar: AppTopBar(
                    title: 'Profile',
                    showBack: false,
                    action: IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => _showEditProfileDialog(context, user),
                    ),
                  ),
                  body: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                      child: Column(
                        children: [
                          SurfaceCard(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 47,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  backgroundImage:
                                      user.photoUrl.trim().isNotEmpty
                                      ? NetworkImage(user.photoUrl)
                                      : null,
                                  child: user.photoUrl.trim().isEmpty
                                      ? const Icon(Icons.person, size: 38)
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 32 / 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRole(user.role),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email.isEmpty ? '-' : user.email,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 18,
                                        color: Color(0xFF2563EB),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Data synced from Firestore',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 24 / 1.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _ProfileInfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'Employee ID',
                                  value: user.employeeId,
                                ),
                                const SizedBox(height: 10),
                                _ProfileInfoRow(
                                  icon: Icons.account_circle_outlined,
                                  label: 'Username',
                                  value: user.username.isEmpty
                                      ? user.employeeId
                                      : user.username,
                                ),
                                const SizedBox(height: 10),
                                _ProfileInfoRow(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: user.phone.isEmpty ? '-' : user.phone,
                                ),
                                const SizedBox(height: 10),
                                _ProfileInfoRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'Office',
                                  value: user.office.isEmpty
                                      ? '-'
                                      : user.office,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledBtnIcon(
                            text: 'Sign Out',
                            icon: Icons.logout_rounded,
                            color: FilledBtnColor.gray,
                            onPressed: onLogout,
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: 2,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.black,
                    onTap: (index) {
                      if (index == 0) {
                        onOpenRepairs();
                      } else if (index == 1) {
                        onOpenScan();
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
                        icon: Icon(Icons.person),
                        label: 'Profile',
                      ),
                    ],
                  ),
                );
      },
    );
  }

  String _formatRole(String role) {
    if (!role.contains('_')) {
      return role;
    }
    return role
        .split('_')
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1)}';
        })
        .join(' ');
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.repository, required this.user});

  final FirestoreRepository repository;
  final UserProfileRecord user;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _roleController;
  late final TextEditingController _phoneController;
  late final TextEditingController _officeController;
  late final TextEditingController _photoController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController(text: widget.user.password);
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _roleController = TextEditingController(text: widget.user.role);
    _phoneController = TextEditingController(text: widget.user.phone);
    _officeController = TextEditingController(text: widget.user.office);
    _photoController = TextEditingController(text: widget.user.photoUrl);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _officeController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.repository.upsertUserProfile(
        widget.user.copyWith(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim().isEmpty
              ? widget.user.password
              : _passwordController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          role: _roleController.text.trim(),
          phone: _phoneController.text.trim(),
          office: _officeController.text.trim(),
          photoUrl: _photoController.text.trim(),
        ),
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
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
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogInput(label: 'Username', controller: _usernameController),
            const SizedBox(height: 10),
            _DialogInput(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            _DialogInput(label: 'Name', controller: _nameController),
            const SizedBox(height: 10),
            _DialogInput(label: 'Email', controller: _emailController),
            const SizedBox(height: 10),
            _DialogInput(label: 'Role', controller: _roleController),
            const SizedBox(height: 10),
            _DialogInput(label: 'Phone', controller: _phoneController),
            const SizedBox(height: 10),
            _DialogInput(label: 'Office', controller: _officeController),
            const SizedBox(height: 10),
            _DialogInput(label: 'Photo URL', controller: _photoController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}

class _DialogInput extends StatelessWidget {
  const _DialogInput({
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

