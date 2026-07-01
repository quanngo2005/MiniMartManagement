import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/login_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_service.dart';
import 'package:mini_mart_management_mobile_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MiniMartManagementApp extends StatelessWidget {
  const MiniMartManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(AuthService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              InventoryProvider(InventoryRepository(InventoryService())),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quản lý Siêu thị',
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
