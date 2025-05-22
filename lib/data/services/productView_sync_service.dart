// lib/data/services/product_view_sync_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repositories/product_view_repository.dart';

import 'package:campus_picks/src/config.dart';



class ProductViewSyncService {
  ProductViewSyncService._();
  static final instance = ProductViewSyncService._();
  final _repo = ProductViewsRepository();

  /// Llama a este método UNA SOLA VEZ, cuando quieras subir vistas pendientes.
  Future<void> syncNow() async {
    final unsent = await _repo.pendingViews(limit: 500);
    if (unsent.isEmpty) return;

    final payload = unsent.map((r) => {
          'productId': r['productId'],
          'userId':    r['userId'],
          'viewedAt':  r['viewedAt'],
        }).toList();

    try {
      final res = await http.post(
        Uri.parse('${Config.apiBaseUrl}/analytics/productViews/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final ids = unsent.map((r) => r['id'] as int).toList();
        await _repo.markViewsSynced(ids);
      }
    } catch (_) {
      // silencio: si falla, no reintentamos aquí
    }
  }
}
