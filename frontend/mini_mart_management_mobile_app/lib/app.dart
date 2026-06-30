import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/category_management_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MiniMartManagementApp extends StatelessWidget {
  const MiniMartManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(AuthRepository(AuthService())),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quản lý Siêu thị',
        theme: AppTheme.light,
        home: const CategoryManagementScreen(),
      ),
    );
  }
}
