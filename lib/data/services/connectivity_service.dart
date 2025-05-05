// lib/data/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../repositories/error_log_repository.dart';

class ConnectivityNotifier extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  
  // La nueva API devuelve un Stream<List<ConnectivityResult>>.
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityNotifier() {
    _init();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (results.isNotEmpty) {
          _connectionStatus = results.first; // Usamos el primer estado como el activo
        } else {
          _connectionStatus = ConnectivityResult.none;
        }

        // Log offline transitions
        if (_connectionStatus == ConnectivityResult.none) {
          await ErrorLogRepository()
              .logError('connectivity_change', 'ConnectivityResult.none');
        }

        notifyListeners();
      },
    );
  }
  
  Future<void> _init() async {
    try {
      // La función checkConnectivity() ahora retorna una lista
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        _connectionStatus = results.first;
      } else {
        _connectionStatus = ConnectivityResult.none;
      }
    } catch (e) {
      // Log connectivity‐check failures
      await ErrorLogRepository()
          .logError('connectivity_check', e.runtimeType.toString());
      _connectionStatus = ConnectivityResult.none;
    }
    notifyListeners();
  }
  
  ConnectivityResult get connectionStatus => _connectionStatus;
  
  // Devuelve "offline" si no hay conexión, "online" en caso contrario.
  String get statusString {
    return _connectionStatus == ConnectivityResult.none ? "offline" : "online";
  }
  
  bool get isOnline => _connectionStatus != ConnectivityResult.none;
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
