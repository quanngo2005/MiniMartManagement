import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/customer_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/receipt_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_lookup_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/receipt_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/login_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_lookup_service.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_service.dart';
import 'package:mini_mart_management_mobile_app/services/receipt_service.dart';
import 'package:mini_mart_management_mobile_app/providers/employee_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/promotion_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/shift_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/tier_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/customer_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/employee_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/promotion_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/shift_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/member_management_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/promotion_management_screen.dart';
import 'package:mini_mart_management_mobile_app/services/customer_service.dart';
import 'package:mini_mart_management_mobile_app/services/employee_service.dart';
import 'package:mini_mart_management_mobile_app/services/promotion_service.dart';
import 'package:mini_mart_management_mobile_app/services/shift_service.dart';
import 'package:mini_mart_management_mobile_app/providers/cart_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/order_repository.dart';
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
        ChangeNotifierProvider(
          create: (_) => InventoryLookupProvider(
            InventoryLookupRepository(InventoryLookupService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider(ReceiptRepository(ReceiptService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EmployeeProvider(EmployeeRepository(EmployeeService())),
        ),
        ChangeNotifierProvider(
          create: (_) => ShiftProvider(ShiftRepository(ShiftService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CustomerProvider(CustomerRepository(CustomerService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PromotionProvider(PromotionRepository(PromotionService())),
        ),
        ChangeNotifierProvider(create: (_) => TierProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider<OrderRepository>(create: (_) => OrderRepository()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quản lý Siêu thị',
        theme: AppTheme.light,
        home: const LoginScreen(),
        routes: {
          '/catalog': (_) => const InventoryTransactionsScreen(),
          '/members': (_) => const MemberManagementScreen(),
          '/promotions': (_) => const PromotionManagementScreen(),
        },
      ),
    );
  }
}
