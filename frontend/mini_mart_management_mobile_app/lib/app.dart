import 'package:flutter/material.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/batch_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_lookup_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/customer_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/inventory_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/receipt_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/supplier_debt_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/stock_count_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/order_return_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/e_invoice_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/report_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/product_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/batch_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/product_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_lookup_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/inventory_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/order_return_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/e_invoice_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/receipt_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/report_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/supplier_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/supplier_debt_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/stock_count_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/cashier_return_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/login_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/employee_performance_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/inventory_transactions_screen.dart';
import 'package:mini_mart_management_mobile_app/screens/settings_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/services/batch_service.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_lookup_service.dart';
import 'package:mini_mart_management_mobile_app/services/inventory_service.dart';
import 'package:mini_mart_management_mobile_app/services/order_return_service.dart';
import 'package:mini_mart_management_mobile_app/services/e_invoice_service.dart';
import 'package:mini_mart_management_mobile_app/services/receipt_service.dart';
import 'package:mini_mart_management_mobile_app/services/report_service.dart';
import 'package:mini_mart_management_mobile_app/services/product_service.dart';
import 'package:mini_mart_management_mobile_app/services/supplier_service.dart';
import 'package:mini_mart_management_mobile_app/services/supplier_debt_service.dart';
import 'package:mini_mart_management_mobile_app/services/stock_count_service.dart';
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
import 'package:mini_mart_management_mobile_app/main.dart';
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
          create: (_) => BatchProvider(BatchRepository(BatchService())),
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
              StockCountProvider(StockCountRepository(StockCountService())),
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
        ChangeNotifierProvider(
          create: (_) => ReportProvider(ReportRepository(ReportService())),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductRepository(ProductService())),
        ),
        ChangeNotifierProvider(create: (_) => TierProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider<OrderRepository>(create: (_) => OrderRepository()),
        ChangeNotifierProvider(
          create: (_) =>
              SupplierProvider(SupplierRepository(SupplierService())),
        ),
        ChangeNotifierProvider(
          create: (_) => SupplierDebtProvider(
            SupplierDebtRepository(SupplierDebtService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              OrderReturnProvider(OrderReturnRepository(OrderReturnService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EInvoiceProvider(EInvoiceRepository(service: EInvoiceService())),
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Quản lý Siêu thị',
        theme: AppTheme.light,
        home: const LoginScreen(),
        routes: {
          '/catalog': (_) => const InventoryTransactionsScreen(),
          '/employee-performance': (_) => const EmployeePerformanceScreen(),
          '/members': (_) => const MemberManagementScreen(),
          '/promotions': (_) => const PromotionManagementScreen(),
          '/returns': (_) => const CashierReturnScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
