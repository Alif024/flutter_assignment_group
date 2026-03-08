import 'package:flutter/material.dart';
import 'package:flutter_assignment_group/components/buttons/blue_btn.dart';
import 'package:flutter_assignment_group/components/cards/surface_card.dart';
import 'package:flutter_assignment_group/components/inputs/input_text_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final Future<void> Function(String username, String password) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_isLoggingIn) {
      return;
    }

    _dismissKeyboard();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Please enter both username and password.');
      return;
    }

    setState(() => _isLoggingIn = true);
    try {
      await widget.onLogin(username, password);
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoggingIn = false);
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

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      controller: _usernameController,
                      label: 'Username',
                      hintText: 'Enter your username',
                      icon: Icons.person,
                      iconPosition: InputIconPosition.right,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    InputTextIcon(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      icon: Icons.visibility_off_outlined,
                      iconPosition: InputIconPosition.right,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitLogin(),
                    ),
                    const SizedBox(height: 22),
                    BlueBtn(
                      text: _isLoggingIn ? 'Logging in...' : 'Login',
                      onPressed: _isLoggingIn ? null : _submitLogin,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Demo: username EMP-1908 / password 123456',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
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
                  Text('Secure Login - Version 2.1.0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
