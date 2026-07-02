import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/manager_navigation_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/mock_role_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/checkout_screen.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/dotted_background.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/loading_overlay.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_card.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_footer.dart';
import 'package:mini_mart_management_mobile_app/widgets/auth/login_header.dart';
import 'package:provider/provider.dart';

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

    final authProvider = context.read<AuthProvider>();
    final user = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) {
            if (_isManager(user)) return ManagerNavigationScreen(user: user);
            if (_isCashier(user)) return const CheckoutScreen();
            return MockRoleScreen(user: user);
          },
        ),
      );
    }
  }

  bool _isManager(EmployeeUser user) {
    return user.roleId == 1 || user.roleId == 5 || user.roleName.toLowerCase() == 'manager' || user.roleName.toLowerCase() == 'quản lý';
  }

  bool _isCashier(EmployeeUser user) {
    return user.roleId == 2 || user.roleId == 6 || user.roleName.toLowerCase() == 'cashier' || user.roleName.toLowerCase() == 'thu ngân';
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>(
      (provider) => provider.isLoading,
    );
    final errorMessage = context.select<AuthProvider, String?>(
      (provider) => provider.errorMessage,
    );

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
                        showError: errorMessage != null,
                        errorMessage: errorMessage,
                        isLoading: isLoading,
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
          if (isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
