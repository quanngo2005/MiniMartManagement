import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/employee_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/employee_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/shift_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/supplier_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/login_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/services/employee_service.dart';
import 'package:mini_mart_management_mobile_app/services/shift_service.dart';
import 'package:mini_mart_management_mobile_app/services/supplier_service.dart';
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
          create: (_) => EmployeeProvider(EmployeeRepository(EmployeeService())),
        ),
        ChangeNotifierProvider(
          create: (_) => ShiftProvider(ShiftRepository(ShiftService())),
        ),
        ChangeNotifierProvider(
          create: (_) => SupplierProvider(SupplierRepository(SupplierService())),
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
