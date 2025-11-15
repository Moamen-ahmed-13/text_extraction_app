import 'package:equatable/equatable.dart';
import 'package:text_extraction_app/data/models/extraction_history_model.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<ExtractionHistoryModel> extractions;

  HistoryLoaded(this.extractions);

  @override
  List<Object?> get props => [extractions];
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class HistoryDeleteSuccess extends HistoryState {}