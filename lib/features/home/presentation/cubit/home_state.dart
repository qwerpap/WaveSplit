import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int selectedSeparationIndex;
  final bool isPickingFile;
  final String? error;
  final int logoTapCount;
  final int logsTapCount;
  final String? recentTrackMessage;

  const HomeState({
    this.selectedSeparationIndex = 1, // По умолчанию 4 stems
    this.isPickingFile = false,
    this.error,
    this.logoTapCount = 0,
    this.logsTapCount = 0,
    this.recentTrackMessage,
  });

  HomeState copyWith({
    int? selectedSeparationIndex,
    bool? isPickingFile,
    String? error,
    int? logoTapCount,
    int? logsTapCount,
    String? recentTrackMessage,
  }) {
    return HomeState(
      selectedSeparationIndex: selectedSeparationIndex ?? this.selectedSeparationIndex,
      isPickingFile: isPickingFile ?? this.isPickingFile,
      error: error,
      logoTapCount: logoTapCount ?? this.logoTapCount,
      logsTapCount: logsTapCount ?? this.logsTapCount,
      recentTrackMessage: recentTrackMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedSeparationIndex,
        isPickingFile,
        error,
        logoTapCount,
        logsTapCount,
        recentTrackMessage,
      ];
}