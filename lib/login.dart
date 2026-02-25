import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_assignment_group/components/buttons/blue_btn.dart';
import 'package:flutter_assignment_group/components/buttons/filled_btn_icon.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/buttons/outlined_btn_icon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 80, height: 80),
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
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
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
                      fontColor: OutlinedBtnFontColor.gray,
                      onPressed: () {
                        // เขียน function ภายนอกได้ที่นี่
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
