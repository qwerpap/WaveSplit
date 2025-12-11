import 'package:flutter/material.dart';
import 'package:wave_split/core/bloc/bloc_providers.dart';
import 'package:wave_split/core/navigation/presentation/widgets/app_router.dart';
import 'package:wave_split/core/theme/app_theme.dart';

void main() {
  BlocProviders.setup();
  runApp(const WaveSplitApp());
}

class WaveSplitApp extends StatelessWidget {
  const WaveSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WaveSplit',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
