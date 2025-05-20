// lib/presentation/product_detail/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../data/models/product_model.dart';
import '../viewmodels/product_detail_viewmodel.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _pageCtrl = PageController();
  bool _descExpanded = true;

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final product = widget.product;

    return Consumer<ProductDetailViewModel>(
      builder: (_, vm, __) {
        final offline = vm.isOffline;

        return Scaffold(
          backgroundColor: scheme.background,
          body: Stack(
            children: [
              // ---------- HERO IMAGE WITH PAGEVIEW ----------
              SizedBox(
                height: 380,
                width: double.infinity,
                child: PageView(
                  controller: _pageCtrl,
                  children: [
                    Hero(
                      tag: 'product-${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                    // If you plan to support multiple images, add more here
                  ],
                ),
              ),

              // ---------- PAGE INDICATOR ----------
              Positioned(
                top: 340,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageCtrl,
                    count: 1,
                    effect: ExpandingDotsEffect(
                      activeDotColor: primary,
                      dotHeight: 6,
                      dotWidth: 6,
                    ),
                  ),
                ),
              ),

              // ---------- OFFLINE BADGE + BACK ----------
              SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: scheme.onPrimary,
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (offline)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OFF-LINE',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),

              // ---------- BOTTOM SHEET ----------
              DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.55,
                maxChildSize: 0.9,
                builder: (context, scrollCtrl) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollCtrl,
                      children: [
                        // drag handle
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.outline.withOpacity(.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // sku / small caption
                        if ((product.category).isNotEmpty)
                          Text(
                            product.category.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(letterSpacing: 1.2),
                          ),
                        // name
                        const SizedBox(height: 6),
                        Text(
                          product.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                        ),

                        const SizedBox(height: 24),

                        // DESCRIPTION header
                        Row(
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                _descExpanded
                                    ? Icons.remove
                                    : Icons.add,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _descExpanded = !_descExpanded),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: Text(
                            (product.description.trim().isNotEmpty)
                                ? product.description
                                : 'No description available.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: _descExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        ),

                        const SizedBox(height: 32),

                        // PRICE + ADD TO CART
                        // ─────────────  PRICE  +  VIEWS  +  ADD TO CART  ─────────────
Row(
  children: [
    // Precio
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    ),

    // Chip de vistas
    const Spacer(),
    Chip(
      avatar: const Icon(Icons.visibility, size: 18),
      label: Text('${context.watch<ProductDetailViewModel>().viewCount}'),
      backgroundColor: primary.withOpacity(.15),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    const SizedBox(width: 12),

    // Botón (sin lógica aún)
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.black,
      ),
      onPressed: () {},          // lo implementará tu compañero
      child: const Text(
        'ADD TO CART',
        style: TextStyle(color: Colors.white, letterSpacing: 0.5),
      ),
    ),
  ],
),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
