import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStatusController.stream;
  bool _isOnline = true;

  ConnectivityService() {
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    _connectionStatusController.add(_isOnline);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isOnline =
        results.isNotEmpty &&
        !results.contains(ConnectivityResult.none) &&
        results.any(
          (result) =>
              result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi ||
              result == ConnectivityResult.ethernet ||
              result == ConnectivityResult.vpn,
        );
    _connectionStatusController.add(_isOnline);
  }

  bool get isOnline => _isOnline;

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty &&
        !result.contains(ConnectivityResult.none) &&
        result.any(
          (r) =>
              r == ConnectivityResult.mobile ||
              r == ConnectivityResult.wifi ||
              r == ConnectivityResult.ethernet ||
              r == ConnectivityResult.vpn,
        );
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
