import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/marketplace_viewmodel.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/models/product_model.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityNotifier()),
        ChangeNotifierProvider(
          create: (_) => MarketplaceViewModel()..fetchProducts(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Marketplace')),
        body: Column(
          children: [
            Consumer<ConnectivityNotifier>(
              builder: (_, conn, __) {
                if (!conn.isOnline) {
                  return Container(
                    width: double.infinity,
                    height: 20,
                    color: Theme.of(context).colorScheme.primary,
                    alignment: Alignment.center,
                    child: const Text(
                      'OFF-LINE  •  showing cached products',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Consumer<MarketplaceViewModel>(
                builder: (_, vm, __) {
                  if (vm.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (vm.error != null) {
                    return Center(child: Text(vm.error!));
                  }
                  final items = vm.products;
                  if (items.isEmpty) {
                    return const Center(child: Text('No products'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .75,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _ProductCard(product: items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.shopping_bag, size: 48),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
