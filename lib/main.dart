import 'package:flutter/material.dart';
import 'package:wave_split/core/bloc/bloc_providers.dart';
import 'package:wave_split/core/navigation/presentation/widgets/app_router.dart';
import 'package:wave_split/core/theme/app_theme.dart';
import 'package:wave_split/core/services/audio_cache_service.dart';
import 'package:wave_split/core/services/network_monitor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем кэш сервис
  await AudioCacheService.initialize();
  
  BlocProviders.setup();
  runApp(const WaveSplitApp());
}

class WaveSplitApp extends StatefulWidget {
  const WaveSplitApp({super.key});

  @override
  State<WaveSplitApp> createState() => _WaveSplitAppState();
}

class _WaveSplitAppState extends State<WaveSplitApp> {
  final NetworkMonitorService _networkMonitor = NetworkMonitorService();

  @override
  void initState() {
    super.initState();
    // Инициализируем мониторинг сети после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _networkMonitor.initialize(context);
    });
  }

  @override
  void dispose() {
    _networkMonitor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WaveSplit',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Инициализируем мониторинг с актуальным контекстом
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _networkMonitor.initialize(context);
        });
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
