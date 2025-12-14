import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {
  const LoadHistoryEvent();
}

class RefreshHistoryEvent extends HistoryEvent {
  const RefreshHistoryEvent();
}

class RemoveTrackFromHistoryEvent extends HistoryEvent {
  final String trackId;

  const RemoveTrackFromHistoryEvent(this.trackId);

  @override
  List<Object?> get props => [trackId];
}

class ClearHistoryEvent extends HistoryEvent {
  const ClearHistoryEvent();
}