import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_extraction_app/data/services/database_helper.dart';
import 'package:text_extraction_app/logic/cubits/history/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final DatabaseHelper _databaseHelper;
  HistoryCubit(this._databaseHelper) : super(HistoryInitial());

  Future<void> loadHistory(String userId) async {
    emit(HistoryLoading());
    try {
      final historyList = await _databaseHelper.getAllExtractions(userId);
      emit(HistoryLoaded(historyList));
    } catch (e) {
      emit(HistoryError('Failed to load history: ${e.toString()}'));
    }
  }
  Future<void> searchHistory(String userId, String query) async {
    emit(HistoryLoading());
    
    try {
      if (query.isEmpty) {
        await loadHistory(userId);
        return;
      }
      
      final extractions = await _databaseHelper.searchExtractions(userId, query);
      emit(HistoryLoaded(extractions));
    } catch (e) {
      emit(HistoryError('Failed to search history: ${e.toString()}'));
    }
  }
 Future<void> deleteExtraction(int id, String userId) async {
    try {
      await _databaseHelper.deleteExtraction(id);
      emit(HistoryDeleteSuccess());
      await loadHistory(userId);
    } catch (e) {
      emit(HistoryError('Failed to delete item: ${e.toString()}'));
    }
  } Future<void> clearAllHistory(String userId) async {
      try {
        await _databaseHelper.deleteAllExtractions(userId);
        emit(HistoryDeleteSuccess());
        await loadHistory(userId);
      } catch (e) {
        emit(HistoryError('Failed to clear history: ${e.toString()}'));
      }
    }
  }
  