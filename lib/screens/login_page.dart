import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_assignment_group/components/buttons/blue_btn.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D66DF),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icons/logo.svg', width: 44),
              ),
              const SizedBox(height: 18),
              const Text(
                'AssetTrack',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Inventory Management System',
                style: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 26),
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to manage your inventory',
                      style: TextStyle(fontSize: 17, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 20),
                    InputTextIcon(
                      controller: _employeeIdController,
                      label: 'Employee ID',
                      hintText: 'Enter your ID',
                      icon: Icons.person,
                      iconPosition: InputIconPosition.right,
                    ),
                    const SizedBox(height: 16),
                    InputTextIcon(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your current password',
                      icon: Icons.visibility_off_outlined,
                      iconPosition: InputIconPosition.right,
                      obscureText: true,
                    ),
                    const SizedBox(height: 22),
                    BlueBtn(text: 'Login', onPressed: widget.onLogin),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Need help accessing your account?',
                style: TextStyle(color: Color(0xFF374151), fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                'Contact IT Support',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Secure Login • Version 2.1.0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
