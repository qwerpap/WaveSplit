import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../constants/strings.dart';
import 'network_test_service.dart';
import '../shared/widgets/network_status_overlay.dart';
import '../../features/separation/presentation/widgets/network_diagnostic_dialog.dart';

enum NetworkStatus {
  connected,
  disconnected,
  poor,
  checking,
}

class NetworkMonitorService {
  static final NetworkMonitorService _instance = NetworkMonitorService._internal();
  factory NetworkMonitorService() => _instance;
  NetworkMonitorService._internal();

  final Talker _talker = GetIt.instance<Talker>();
  
  Timer? _monitorTimer;
  NetworkStatus _currentStatus = NetworkStatus.checking;
  OverlayEntry? _overlayEntry;
  BuildContext? _context;
  
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;
  NetworkStatus get currentStatus => _currentStatus;

  bool _isMonitoring = false;
  bool _overlayVisible = false;
  DateTime? _lastFailureTime;
  int _consecutiveFailures = 0;

  void initialize(BuildContext context) {
    _context = context;
    _startMonitoring();
  }

  void dispose() {
    _stopMonitoring();
    _hideOverlay();
    _statusController.close();
  }

  void _startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _talker.info('Network monitoring started');
    
    _checkNetworkStatus();
    
    _monitorTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNetworkStatus();
    });
  }

  void _stopMonitoring() {
    _isMonitoring = false;
    _monitorTimer?.cancel();
    _monitorTimer = null;
    _talker.info('Network monitoring stopped');
  }

  Future<void> _checkNetworkStatus() async {
    if (!_isMonitoring) return;

    _updateStatus(NetworkStatus.checking);

    try {
      final result = await NetworkTestService.testApiConnection();
      
      if (result.success) {
        _consecutiveFailures = 0;
        _lastFailureTime = null;
        _updateStatus(NetworkStatus.connected);
        _hideOverlay();
      } else {
        _consecutiveFailures++;
        _lastFailureTime = DateTime.now();
        
        if (result.message.toLowerCase().contains('timeout') || 
            result.message.toLowerCase().contains('slow')) {
          _updateStatus(NetworkStatus.poor);
        } else {
          _updateStatus(NetworkStatus.disconnected);
        }
        
        _showOverlay();
      }
    } catch (e) {
      _consecutiveFailures++;
      _lastFailureTime = DateTime.now();
      _updateStatus(NetworkStatus.disconnected);
      _showOverlay();
      _talker.error('Network check failed: $e');
    }
  }

  Future<bool> checkNetworkForCriticalOperation() async {
    _talker.info('Checking network for critical operation');
    
    _updateStatus(NetworkStatus.checking);
    
    try {
      final result = await NetworkTestService.testApiConnection();
      
      if (result.success) {
        _consecutiveFailures = 0;
        _updateStatus(NetworkStatus.connected);
        _hideOverlay();
        return true;
      } else {
        _consecutiveFailures++;
        _updateStatus(result.message.toLowerCase().contains('timeout') 
            ? NetworkStatus.poor 
            : NetworkStatus.disconnected);
        _showOverlay();
        return false;
      }
    } catch (e) {
      _consecutiveFailures++;
      _updateStatus(NetworkStatus.disconnected);
      _showOverlay();
      _talker.error('Critical network check failed: $e');
      return false;
    }
  }

  void _updateStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      _talker.info('Network status changed to: ${status.name}');
    }
  }

  void _showOverlay() {
    if (_overlayVisible || _context == null) return;

    _overlayVisible = true;
    
    final overlay = Overlay.of(_context!);
    _overlayEntry = OverlayEntry(
      builder: (context) => NetworkStatusOverlay(
        status: _currentStatus,
        consecutiveFailures: _consecutiveFailures,
        lastFailureTime: _lastFailureTime,
        onDismiss: _hideOverlay,
        onRetry: () {
          _hideOverlay();
          _checkNetworkStatus();
        },
        onDiagnose: () {
          _hideOverlay();
          _showDiagnosticDialog();
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    if (!_overlayVisible) return;
    
    _overlayVisible = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDiagnosticDialog() {
    if (_context == null) return;
    
    showDialog(
      context: _context!,
      builder: (context) => const NetworkDiagnosticDialog(),
    );
  }

  String getStatusMessage() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return AppStrings.networkConnected;
      case NetworkStatus.disconnected:
        return AppStrings.networkDisconnected;
      case NetworkStatus.poor:
        return AppStrings.networkPoor;
      case NetworkStatus.checking:
        return AppStrings.networkChecking;
    }
  }

  Color getStatusColor() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return const Color(0xFF10B981);
      case NetworkStatus.disconnected:
        return const Color(0xFFEF4444);
      case NetworkStatus.poor:
        return const Color(0xFFF59E0B);
      case NetworkStatus.checking:
        return const Color(0xFF6B7280);
    }
  }

  IconData getStatusIcon() {
    switch (_currentStatus) {
      case NetworkStatus.connected:
        return Icons.wifi;
      case NetworkStatus.disconnected:
        return Icons.wifi_off;
      case NetworkStatus.poor:
        return Icons.signal_wifi_bad;
      case NetworkStatus.checking:
        return Icons.wifi_find;
    }
  }
}