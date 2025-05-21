// lib/presentation/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/marketplace_viewmodel.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/models/product_model.dart';

import '../viewmodels/product_detail_viewmodel.dart';
import '../screens/product_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityNotifier()),
        ChangeNotifierProvider(create: (_) => MarketplaceViewModel()..fetchProducts()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Marketplace'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Consumer<ConnectivityNotifier>(builder: (context, conn, _) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: conn.isOnline ? 0 : 24),
                child: Consumer<MarketplaceViewModel>(builder: (_, vm, __) {
                  if (vm.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.error != null) {
                    return Center(child: Text(vm.error!, style: theme.textTheme.bodyMedium));
                  }

                  final filtered = vm.products.where((p) {
                    return p.name.toLowerCase().contains(_searchQuery) ||
                        p.category.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('No products found', style: theme.textTheme.bodyLarge));
                  }

                  return RefreshIndicator(
                    onRefresh: vm.fetchProducts,
                    color: theme.colorScheme.primary,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final prod = filtered[i];
                        return _ProductCard(
                          product: prod,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (ctx) => ProductDetailViewModel(
                                    product: prod,
                                    connectivity: Provider.of<ConnectivityNotifier>(ctx, listen: false),
                                  ),
                                  child: ProductDetailPage(product: prod),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
              if (!conn.isOnline)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24,
                    color: theme.colorScheme.primary,
                    alignment: Alignment.center,
                    child: Text(
                      'OFFLINE • showing cached products',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int length = product.name.length;
    double fontSize = theme.textTheme.titleMedium!.fontSize!;
    if (length > 25) {
      fontSize = 10;
    } else if (length > 15) {
      fontSize = fontSize * 0.75;
    }
    final titleStyle = theme.textTheme.titleMedium?.copyWith(fontSize: fontSize);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
