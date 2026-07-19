import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/providers/auth_provider.dart';
import 'package:mini_mart_management_mobile_app/providers/stock_count_provider.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/repositories/stock_count_repository.dart';
import 'package:mini_mart_management_mobile_app/screens/stock_count_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';
import 'package:mini_mart_management_mobile_app/services/stock_count_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('supports blank, zero, manual, and stepper quantity values', (
    tester,
  ) async {
    final repository = _FakeStockCountRepository(_count());
    await tester.pumpWidget(
      ChangeNotifierProvider<StockCountProvider>(
        create: (_) => StockCountProvider(repository),
        child: const MaterialApp(home: StockCountDetailScreen(stockCountId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    expect(field, findsOneWidget);

    await tester.enterText(field, '0');
    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(repository.savedLines.single.actualQuantity, 0);

    await tester.enterText(field, '12');
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(repository.savedLines.single.actualQuantity, 13);

    await tester.enterText(field, '');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(repository.savedLines.single.actualQuantity, isNull);
  });

  testWidgets('allows a manager to cancel a draft stock count', (tester) async {
    final repository = _FakeStockCountRepository(_draftCount());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StockCountProvider>(
            create: (_) => StockCountProvider(repository),
          ),
          ChangeNotifierProvider<AuthProvider>.value(
            value: _FakeAuthProvider(),
          ),
        ],
        child: const MaterialApp(home: StockCountDetailScreen(stockCountId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa phiếu nháp'));
    await tester.pumpAndSettle();
    expect(find.text('Hủy phiếu kiểm kê nháp'), findsOneWidget);

    await tester.tap(find.text('Hủy phiếu'));
    await tester.pumpAndSettle();
    expect(repository.cancelled, isTrue);
  });
}

class _FakeStockCountRepository extends StockCountRepository {
  _FakeStockCountRepository(this.count) : super(StockCountService());

  StockCount count;
  List<StockCountLine> savedLines = const [];
  bool cancelled = false;

  @override
  Future<StockCount> getDetail(int id) async => count;

  @override
  Future<StockCount> updateLines(
    StockCount count,
    List<StockCountLine> lines,
  ) async {
    savedLines = lines;
    this.count = StockCount(
      stockCountId: count.stockCountId,
      stockCountCode: count.stockCountCode,
      scope: count.scope,
      status: count.status,
      createdAt: count.createdAt,
      createdByEmployeeId: count.createdByEmployeeId,
      createdByEmployeeName: count.createdByEmployeeName,
      rowVersion: count.rowVersion,
      lines: lines,
    );
    return this.count;
  }

  @override
  Future<StockCount> cancelDraft(StockCount count) async {
    cancelled = true;
    this.count = StockCount(
      stockCountId: count.stockCountId,
      stockCountCode: count.stockCountCode,
      scope: count.scope,
      status: StockCountStatus.cancelled,
      createdAt: count.createdAt,
      createdByEmployeeId: count.createdByEmployeeId,
      createdByEmployeeName: count.createdByEmployeeName,
      rowVersion: count.rowVersion,
    );
    return this.count;
  }

  @override
  Future<List<StockCount>> fetchStockCounts() async => [count];
}

StockCount _count() => StockCount(
  stockCountId: 1,
  stockCountCode: 'SC-001',
  scope: StockCountScope.global,
  status: StockCountStatus.counting,
  createdAt: DateTime.utc(2026, 7, 18),
  createdByEmployeeId: 1,
  createdByEmployeeName: 'Warehouse Staff',
  rowVersion: 'count-version',
  lines: const [
    StockCountLine(
      stockCountLineId: 10,
      productId: 20,
      productCode: 'P-20',
      productName: 'Product',
      snapshotQuantity: 3,
      actualQuantity: null,
      variance: null,
      note: null,
      rowVersion: 'line-version',
    ),
  ],
);

StockCount _draftCount() => StockCount(
  stockCountId: 1,
  stockCountCode: 'SC-001',
  scope: StockCountScope.global,
  status: StockCountStatus.draft,
  createdAt: DateTime.utc(2026, 7, 18),
  createdByEmployeeId: 1,
  createdByEmployeeName: 'Warehouse Staff',
  rowVersion: 'count-version',
);

class _FakeAuthProvider extends AuthProvider {
  _FakeAuthProvider() : super(AuthRepository(AuthService()));

  @override
  EmployeeUser? get currentUser => EmployeeUser(
    employeeId: 1,
    fullName: 'Manager',
    gender: true,
    dateOfBirth: DateTime.utc(1990, 1, 1),
    username: 'manager',
    status: 1,
    roleId: 1,
    roleName: 'Manager',
    permissions: [],
  );
}
