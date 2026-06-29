import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/dotted_background.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_footer.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showError = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _showError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _showError = true;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DottedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoginHeader(),
                      const SizedBox(height: 40),
                      LoginCard(
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        usernameFocus: _usernameFocus,
                        passwordFocus: _passwordFocus,
                        obscurePassword: _obscurePassword,
                        showError: _showError,
                        isLoading: _isLoading,
                        onTogglePassword: _togglePasswordVisibility,
                        onSubmit: _handleLogin,
                      ),
                      const SizedBox(height: 48),
                      const LoginFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
