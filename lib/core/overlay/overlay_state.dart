import 'package:equatable/equatable.dart';

enum OverlayPhase { none, uploading, processing }

class OverlayState extends Equatable {
  final OverlayPhase phase;
  final String? message;
  final double uiTarget;
  final double logicalProgress;
  final bool visible;

  const OverlayState({
    this.phase = OverlayPhase.none,
    this.message,
    this.uiTarget = 0.0,
    this.logicalProgress = 0.0,
    this.visible = false,
  });

  OverlayState copyWith({
    OverlayPhase? phase,
    String? message,
    double? uiTarget,
    double? logicalProgress,
    bool? visible,
  }) {
    return OverlayState(
      phase: phase ?? this.phase,
      message: message ?? this.message,
      uiTarget: uiTarget ?? this.uiTarget,
      logicalProgress: logicalProgress ?? this.logicalProgress,
      visible: visible ?? this.visible,
    );
  }

  @override
  List<Object?> get props => [phase, message, uiTarget, logicalProgress, visible];
}
