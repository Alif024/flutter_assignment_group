import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_assignment_group/components/buttons/blue_btn.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/buttons/outlined_btn_icon.dart';
import 'package:flutter_assignment_group/components/cards/recent_activity_card.dart';

class TestComponents extends StatefulWidget {
  const TestComponents({super.key});

  @override
  State<TestComponents> createState() => _TestComponentsState();
}

class _TestComponentsState extends State<TestComponents> {
  final TextEditingController _assetIdController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _assetIdController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Add login action here later
    debugPrint('Asset ID: ${_assetIdController.text}');
    debugPrint('Employee ID: ${_employeeIdController.text}');
    debugPrint('Password: ${_passwordController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please login to your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        InputTextIcon(
                          controller: _assetIdController,
                          label: 'Asset ID',
                          hintText: 'Enter Asset ID',
                          icon: Icons.tag,
                          iconPosition: InputIconPosition.left,
                          onChanged: (value) {
                            debugPrint('assetId changed: $value');
                          },
                        ),
                        const SizedBox(height: 20),
                        InputTextIcon(
                          controller: _employeeIdController,
                          label: 'Employee ID',
                          hintText: 'Enter your ID',
                          icon: Icons.person,
                          iconPosition: InputIconPosition.right,
                          onChanged: (value) {
                            debugPrint('employeeId changed: $value');
                          },
                        ),
                        const SizedBox(height: 20),
                        InputTextIcon(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          icon: Icons.lock,
                          iconPosition: InputIconPosition.right,
                          obscureText: true,
                          onChanged: (value) {
                            debugPrint('password changed: $value');
                          },
                        ),
                        const SizedBox(height: 30),
                        BlueBtn(text: 'Login', onPressed: _handleLogin),
                        const SizedBox(height: 20),
                        FilledBtnIcon(
                          text: 'Scan QR Code',
                          icon: Icons.qr_code_scanner,
                          color: FilledBtnColor.green,
                          onPressed: () {
                            // เขียน function ภายนอกได้ที่นี่
                          },
                        ),
                        const SizedBox(height: 20),
                        OutlinedBtnIcon(
                          text: 'Login with Google',
                          icon: Icons.login,
                          fontColor: OutlinedBtnFontColor.red,
                          onPressed: () {
                            // เขียน function ภายนอกได้ที่นี่
                          },
                        ),
                        const SizedBox(height: 20),
                        RecentActivityCard(
                          title: 'Dell Latitude 5420',
                          activityText: 'Status updated',
                          timeText: '2 hours ago',
                          statusText: 'Normal',
                          icon: Icons.laptop_mac_rounded,
                          iconColor: const Color(0xFF2D6AE3),
                          statusColor: const Color(0xFF22A447),
                          onTap: () {
                            debugPrint('Card tapped');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
