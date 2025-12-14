import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:wave_split/features/separation/domain/usecases/start_separation.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../navigation/presentation/cubit/navigation_cubit.dart';
import '../overlay/overlay_cubit.dart';
import '../../constants/api_constants.dart';
import '../../features/separation/data/datasources/separation_remote_datasource.dart';
import '../../features/separation/data/repositories/separation_repository_impl.dart';
import '../../features/separation/presentation/bloc/separation_bloc.dart';
import '../../features/history/data/datasources/history_local_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

final GetIt getIt = GetIt.instance;

class BlocProviders {
  BlocProviders._();

  static void setup() {
    _registerTalker();
    _registerNavigationCubit();
    _registerHistory();
    _registerSeparation();
  }

  static void _registerTalker() {
    getIt.registerLazySingleton<Talker>(() => TalkerFlutter.init());
  }

  static void _registerNavigationCubit() {
    getIt.registerFactoryParam<NavigationCubit, String, bool>(
      (currentLocation, isDark) => NavigationCubit(
        currentLocation: currentLocation,
        isDark: isDark,
      ),
    );
  }

  static void _registerSeparation() {
    // Dio client for API calls
    getIt.registerLazySingleton<Dio>(
      () => Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
    );

    // Remote datasource
    getIt.registerFactory<SeparationRemoteDataSource>(
      () => SeparationRemoteDataSource(
        dio: getIt<Dio>(),
        talker: getIt<Talker>(),
      ),
    );

    // Repository
    getIt.registerFactory<SeparationRepositoryImpl>(
      () => SeparationRepositoryImpl(remote: getIt<SeparationRemoteDataSource>()),
    );

    // Usecase
    getIt.registerFactory<StartSeparation>(
      () => StartSeparation(getIt<SeparationRepositoryImpl>()),
    );

    // Bloc
    getIt.registerFactory(
      () => SeparationBloc(
        repository: getIt<SeparationRepositoryImpl>(),
        historyRepository: getIt<HistoryRepositoryImpl>(),
      ),
    );
    // Overlay cubit (single instance)
    getIt.registerLazySingleton<OverlayCubit>(() => OverlayCubit());
  }

  static void _registerHistory() {
    // Local datasource
    getIt.registerLazySingleton<HistoryLocalDataSource>(
      () => HistoryLocalDataSourceImpl(),
    );

    // Repository
    getIt.registerLazySingleton<HistoryRepositoryImpl>(
      () => HistoryRepositoryImpl(localDataSource: getIt<HistoryLocalDataSource>()),
    );

    // Bloc
    getIt.registerFactory(
      () => HistoryBloc(repository: getIt<HistoryRepositoryImpl>()),
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
        BlocProvider(
          create: (_) => getIt<SeparationBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<OverlayCubit>(),
        ),
        BlocProvider(
          create: (_) => getIt<HistoryBloc>(),
        ),
      ],
      child: child,
    );
  }
}

