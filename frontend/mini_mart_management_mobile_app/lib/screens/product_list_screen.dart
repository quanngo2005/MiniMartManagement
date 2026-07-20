import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_mart_management_mobile_app/models/product.dart';
import 'package:mini_mart_management_mobile_app/providers/product_provider.dart';
import 'package:mini_mart_management_mobile_app/screens/product_detail_screen.dart';
import 'package:mini_mart_management_mobile_app/theme/app_colors.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/empty_state.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/error_banner.dart';
import 'package:mini_mart_management_mobile_app/widgets/feedback/loading_overlay.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAll();
    });
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _filtered(List<Product> all) {
    if (_query.isEmpty) return all;
    return all.where((p) {
      return p.productName.toLowerCase().contains(_query) ||
          p.productCode.toLowerCase().contains(_query) ||
          p.barcode.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final filtered = _filtered(provider.products);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody(context, provider, filtered)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceContainerLowest,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      foregroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Quản lý Sản Phẩm',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.borderGray, height: 1),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.backgroundSlate,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.outlineVariant,
          ),
          hintText: 'Tìm theo tên, mã SKU, barcode...',
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductProvider provider,
    List<Product> filtered,
  ) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const LoadingOverlay();
    }
    if (provider.error != null && provider.products.isEmpty) {
      return ErrorBanner(
        message: provider.error!,
        onRetry: () => context.read<ProductProvider>().fetchAll(),
      );
    }
    if (filtered.isEmpty) {
      return EmptyState(
        message: _query.isNotEmpty
            ? 'Không tìm thấy sản phẩm phù hợp.'
            : 'Chưa có sản phẩm nào.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ProductProvider>().fetchAll(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ProductTile(
          product: filtered[i],
          onTap: () => _openDetail(context, filtered[i]),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
    );
  }
}

// ─── Product tile ─────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        product.minimumStock > 0 &&
        product.stockQuantity <= product.minimumStock;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrl(product),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SKU: ${product.productCode}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (product.categoryName != null)
                      Text(
                        product.categoryName!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmtPrice(product.sellingPrice),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isLowStock
                          ? AppColors.errorContainer
                          : AppColors.secondaryFixed.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Kho: ${product.stockQuantity}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isLowStock
                            ? AppColors.statusError
                            : AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtPrice(double price) {
    final str = price.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '$bufđ';
  }

  String _imageUrl(Product product) {
    final url = product.imageUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    return switch (product.productCode) {
      'SP001' =>
        'https://storage.googleapis.com/tm-zopsmart-uploads/1/images/640/20250417/3296881-20250417-161955.webp',
      'SP002' =>
        'https://upload.wikimedia.org/wikipedia/commons/2/29/La_Vie_bottle.jpg',
      'SP003' =>
        'https://tiimg.tistatic.com/fp/1/006/506/pepsi-cola-canned-soda-330ml-539.jpg',
      'SP004' =>
        'https://tiimg.tistatic.com/fp/1/006/506/coca-cola-soft-drink-330ml-can-539.jpg',
      'SP011' =>
        'https://www.crackerjack.co.nz/cdn/shop/products/oreo-original-sandwich-chocolate-1196g-fs1675.jpg',
      'SP012' => 'https://www.pns.hk/cdn/shop/products/448372_1_1024x1024.jpg',
      'SP014' =>
        'https://www.worldwideholland.com/cdn/shop/products/haribo-gold-bears-250-gr-1_1024x1024.jpg',
      'SP015' =>
        'https://cdn.shopify.com/s/files/1/0550/6322/3094/products/LaysOriginal50g_1024x1024.jpg',
      'SP018' =>
        'https://www.avakids.com/images/products/2024/03/07/large/sua-tuoi-vinamilk-it-duong-1-lit-1-hop_1712572233.jpg',
      'SP020' =>
        'https://www.sieuthianhduong.com/upload/product/sua-milo-180ml-4-hop_1620202344.jpg',
      'SP024' =>
        'https://osifood.vn/cdn/shop/products/mi-hao-hao-tom-chua-cay-goi-75g_1024x1024.jpg',
      'SP029' =>
        'https://www.chin-su.com.vn/uploads/products/nuoc-mam-ca-hoi-500ml.jpg',
      'SP030' =>
        'https://www.chin-su.com.vn/uploads/products/tuong-ot-chin-su-250g.jpg',
      _ => 'https://placehold.co/320x320/png?text=${product.productCode}',
    };
  }
}
