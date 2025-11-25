import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../navigation/presentation/cubit/navigation_cubit.dart';

final GetIt getIt = GetIt.instance;

class BlocProviders {
  BlocProviders._();

  static void setup() {
    _registerNavigationCubit();
  }

  static void _registerNavigationCubit() {
    getIt.registerFactoryParam<NavigationCubit, String, bool>(
      (currentLocation, isDark) => NavigationCubit(
        currentLocation: currentLocation,
        isDark: isDark,
      ),
    );
  }

  static Widget wrapWithProviders({
    required BuildContext context,
    required Widget child,
  }) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider<NavigationCubit>(
          create: (_) => getIt<NavigationCubit>(
            param1: currentLocation,
            param2: isDark,
          ),
        ),
      ],
      child: child,
    );
  }
}

