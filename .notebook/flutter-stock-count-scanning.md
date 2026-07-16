# Flutter Stock Count Scanning
> Live count UI reuses the existing barcode scan flow

Entry: `frontend/mini_mart_management_mobile_app/lib/screens/stock_count_detail_screen.dart:StockCountDetailScreen`

Scan flow: `StockCountDetailScreen._openBarcodeScanner()` → `screens/barcode_scanner_screen.dart:BarcodeScannerScreen` → `List<ScannedProduct>` → local count lines.

Count state: screen-local until a frontend StockCount model/service/provider exists; product expected quantity comes from `models/product_lookup.dart:ProductLookup.stockQuantity`.

Entry point: `screens/inventory_documents_screen.dart:_InventoryDocumentsScreenState._buildAppBar()` → stock-count action.

History flow: `screens/stock_count_history_screen.dart:StockCountHistoryScreen` → `providers/stock_count_provider.dart:StockCountProvider.loadStockCounts()` → `repositories/stock_count_repository.dart:StockCountRepository.fetchStockCounts()` → `services/stock_count_service.dart:StockCountService.fetchStockCounts()` → `GET /api/stock-counts`.

Mapping: `backend/MiniMart/Dtos/StockCountDtos.cs:StockCountListDto` → `models/stock_count.dart:StockCount`; enum JSON accepts the API's numeric and string forms. Detail/line persistence is not yet wired to the frontend.

Updated: 2026-07-16
