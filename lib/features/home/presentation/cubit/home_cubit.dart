import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../constants/strings.dart';
import '../../../../core/utils/file_utils.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../core/services/network_monitor_service.dart';
import '../../../separation/presentation/bloc/separation_bloc.dart';
import '../../../separation/presentation/bloc/separation_event.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../history/presentation/bloc/history_event.dart';
import '../../data/home_data.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SeparationBloc _separationBloc;
  final HistoryBloc _historyBloc;
  final Talker _talker = GetIt.instance<Talker>();
  final NetworkMonitorService _networkMonitor = NetworkMonitorService();

  HomeCubit({
    required SeparationBloc separationBloc,
    required HistoryBloc historyBloc,
  })  : _separationBloc = separationBloc,
        _historyBloc = historyBloc,
        super(const HomeState());

  void initialize() {
    _loadHistory();
  }

  void _loadHistory() {
    _historyBloc.add(const LoadHistoryEvent());
  }

  void refreshHistory() {
    _historyBloc.add(const RefreshHistoryEvent());
  }

  void selectSeparationMode(int index) {
    if (index >= 0 && index < kSeparationOptions.length) {
      emit(state.copyWith(selectedSeparationIndex: index));
    }
  }

  Future<void> uploadFile() async {
    if (state.isPickingFile) {
      _talker.warning('File picker already in progress, ignoring request');
      return;
    }

    _talker.info('Setting isPickingFile to true');
    emit(state.copyWith(isPickingFile: true));

    try {
      _talker.info('Starting file picker');
      
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      _talker.info('File picker completed, result: ${result != null ? 'success' : 'cancelled'}');

      if (result == null || result.files.isEmpty) {
        _talker.info('File picker cancelled by user');
        emit(state.copyWith(isPickingFile: false));
        return;
      }

      final file = result.files.first;
      _talker.info('Selected file: ${file.name}, path: ${file.path}');
      
      final validationError = _validateSelectedFile(file);
      if (validationError != null) {
        _talker.warning('File validation failed: $validationError');
        emit(state.copyWith(
          isPickingFile: false,
          error: validationError,
        ));
        return;
      }

      _talker.info('File validation passed, starting separation');
      await _startSeparation(file.path!, file.name);
      
    } catch (e) {
      _talker.error('File picking failed: $e');
      
      final errorMessage = e.toString();
      if (!errorMessage.contains('multiple_request') && 
          !errorMessage.contains('Cancelled by a second request')) {
        emit(state.copyWith(
          isPickingFile: false,
          error: 'File picking failed: $errorMessage',
        ));
      } else {
        _talker.info('File picker cancelled (multiple request or user cancellation)');
        emit(state.copyWith(isPickingFile: false));
      }
    } finally {
      if (state.isPickingFile) {
        _talker.info('Force resetting isPickingFile to false in finally block');
        emit(state.copyWith(isPickingFile: false));
      }
    }
  }

  String? _validateSelectedFile(PlatformFile file) {
    if (file.path == null || file.path!.isEmpty) {
      return 'Selected file path is invalid';
    }

    if (!ValidationUtils.isValidFilePath(file.path)) {
      return 'Invalid file path format';
    }

    if (!FileUtils.isAudioFile(file.path!)) {
      return 'Please select an audio file (mp3, wav, flac, etc.)';
    }

    if (file.size > 100 * 1024 * 1024) {
      return 'File size too large. Maximum size is 100MB';
    }

    return null;
  }

  Future<void> _startSeparation(String filePath, String fileName) async {
    try {
      _talker.info('Checking network before starting separation');
      final networkOk = await _networkMonitor.checkNetworkForCriticalOperation();
      
      if (!networkOk) {
        emit(state.copyWith(
          isPickingFile: false,
          error: AppStrings.networkRequiredForProcessing,
        ));
        return;
      }

      final selectedOption = kSeparationOptions[state.selectedSeparationIndex];
      final model = selectedOption.id == '2stems' ? 'two_stems' : 'four_stems';
      
      _talker.info('Starting separation | file=$fileName | model=$model');
      
      _separationBloc.add(StartSeparationEvent(
        filePath: filePath,
        model: model,
      ));

      emit(state.copyWith(
        isPickingFile: false,
        error: null,
      ));
      
    } catch (e) {
      _talker.error('Failed to start separation: $e');
      emit(state.copyWith(
        isPickingFile: false,
        error: 'Failed to start separation: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void incrementLogoTapCount() {
    final newCount = state.logoTapCount + 1;
    emit(state.copyWith(logoTapCount: newCount));
  }

  void incrementLogsTapCount() {
    final newCount = state.logsTapCount + 1;
    emit(state.copyWith(logsTapCount: newCount));
  }

  void resetTapCounts() {
    emit(state.copyWith(
      logoTapCount: 0,
      logsTapCount: 0,
    ));
  }

  void playRecentTrack(String trackName, String modelName) {
    _talker.info('Playing recent track: $trackName - $modelName');
    emit(state.copyWith(
      recentTrackMessage: 'Playing $trackName - $modelName',
    ));
  }

  void clearRecentTrackMessage() {
    emit(state.copyWith(recentTrackMessage: null));
  }

  void resetPickingState() {
    _talker.info('Force resetting picking state');
    emit(state.copyWith(isPickingFile: false));
  }
}