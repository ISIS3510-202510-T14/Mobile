import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/services/metrics_management.dart' as metrics_management;
import '../../src/config.dart';

class MarketplaceViewModel extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();
  final ErrorLogRepository _errorRepo = ErrorLogRepository();

  List<Product> products = [];
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();

    final startTime = DateTime.now();
    int duration = 0;
    bool success = false;
    int? statusCode;
    String? error;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity == ConnectivityResult.none;

      if (isOffline) {
        products = await _repo.getAllProducts();
      } else {
        // Return cached data if still valid
        final cached = _repo.memoryCache;
        if (cached != null) {
          products = cached;
          success = true;
          _error = null;
        } else {
          final url = Uri.parse('${Config.apiBaseUrl}/api/products');
          final response = await http.get(url);

          duration = DateTime.now().difference(startTime).inMilliseconds;
          statusCode = response.statusCode;

          if (response.statusCode == 200) {
            // final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
            // products = await compute(_parseProducts, jsonList);
            // Decode the top-level object, then extract the "products" list
            final decoded = json.decode(response.body);
            if (decoded is Map<String, dynamic> && decoded['products'] is List) {
              final List<dynamic> jsonList = decoded['products'] as List<dynamic>;
              products = await compute(_parseProducts, jsonList);
            } else {
              throw FormatException(
                'Expected JSON with a top-level "products" array'
              );
            }
            success = true;
            _error = null;

            // update caches
            _repo.updateCache(products);
            for (final p in products) {
              await _repo.insertProduct(p);
            }
          } else {
            error = 'BadStatus${response.statusCode}';
            await _errorRepo.logError('/api/products', error);
            _error = 'Error: ${response.statusCode}';
          }
        }
      }
    } catch (e) {
      duration = DateTime.now().difference(startTime).inMilliseconds;
      error = e.runtimeType.toString();
      await _errorRepo.logError('/api/products', error);
      _error = e.toString();
    }

    await metrics_management.logApiMetric(
      endpoint: '/api/products',
      duration: duration,
      statusCode: statusCode,
      success: success,
      error: error,
    );

    _loading = false;
    notifyListeners();
  }
}

List<Product> _parseProducts(List<dynamic> jsonList) {
  return jsonList.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
}
