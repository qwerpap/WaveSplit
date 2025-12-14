import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/progress_constants.dart';
import 'overlay_state.dart';

class OverlayCubit extends Cubit<OverlayState> {
  OverlayCubit() : super(const OverlayState());

  Timer? _debounce;
  double _display = 0.0;
  Timer? _smoothingTimer;
  static const int _frameMs = 40;

  void showRequested({OverlayPhase phase = OverlayPhase.none, String? message, double? progress}) {
    final p = progress ?? state.logicalProgress;
    if (p >= ProgressConstants.showThreshold) {
      final ui = _mapToUi(p, phase);
      emit(state.copyWith(phase: phase, message: message, logicalProgress: p, uiTarget: _display, visible: true));
      _startSmoothing(ui);
    } else {
      emit(state.copyWith(phase: phase, message: message, logicalProgress: p));
      _debounce?.cancel();
      _debounce = Timer(Duration(milliseconds: ProgressConstants.showDebounceMs), () {
        final ui = _mapToUi(state.logicalProgress, phase);
        emit(state.copyWith(phase: phase, message: message, uiTarget: _display, visible: true));
        _startSmoothing(ui);
      });
    }
  }

  void updateProgress({OverlayPhase? phase, String? message, required double progress}) {
    _debounce?.cancel();
    final ui = _mapToUi(progress, phase ?? state.phase);

    emit(state.copyWith(phase: phase ?? state.phase, message: message ?? state.message, logicalProgress: progress, uiTarget: _display, visible: state.visible || progress >= ProgressConstants.showThreshold));
    if (ui > _display) _startSmoothing(ui);
  }

  void hideRequested() {
    emit(state.copyWith(uiTarget: _display, logicalProgress: 1.0, visible: true));
    _startSmoothing(1.0, fast: true);
  }

  double _mapToUi(double logical, OverlayPhase phase) {
    if (phase == OverlayPhase.uploading) {
      return (logical.clamp(0.0, 1.0)) * ProgressConstants.uploadUiMax;
    } else if (phase == OverlayPhase.processing) {
      return ProgressConstants.uploadUiMax + (logical.clamp(0.0, 1.0)) * (ProgressConstants.processingUiMax - ProgressConstants.uploadUiMax);
    }
    return logical.clamp(0.0, 1.0);
  }

  void _startSmoothing(double target, {bool fast = false}) {
    _smoothingTimer?.cancel();
    final t = target.clamp(0.0, 1.0);
    if (t <= _display + 0.00001) return;

    final delta = t - _display;
    final base = ProgressConstants.animBaseMs;
    final max = ProgressConstants.animMaxMs;
    final durationMs = fast ? 300 : (base + (delta * (max - base))).toInt().clamp(base, max);
    final steps = (durationMs / _frameMs).ceil().clamp(2, 200);
    final stepInc = delta / steps;
    var stepCount = 0;

    _smoothingTimer = Timer.periodic(Duration(milliseconds: _frameMs), (timer) {
      stepCount++;
      _display = (_display + stepInc).clamp(0.0, t);
      emit(state.copyWith(uiTarget: _display));
      if (stepCount >= steps || _display >= t - 0.00001) {
        _display = t;
        emit(state.copyWith(uiTarget: _display));
        timer.cancel();
        _smoothingTimer = null;
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _smoothingTimer?.cancel();
    return super.close();
  }

  void reset() {
    _debounce?.cancel();
    _smoothingTimer?.cancel();
    _display = 0.0;
    emit(const OverlayState());
  }
}
