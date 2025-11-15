import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/history_repository.dart';

class HistoryState {
  final List<Map<String, dynamic>> essay;
  final List<Map<String, dynamic>> interview;
  final bool loading;
  HistoryState({
    this.essay = const [],
    this.interview = const [],
    this.loading = false,
  });

  HistoryState copyWith({
    List<Map<String, dynamic>>? essay,
    List<Map<String, dynamic>>? interview,
    bool? loading,
  }) => HistoryState(
    essay: essay ?? this.essay,
    interview: interview ?? this.interview,
    loading: loading ?? this.loading,
  );
}

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository repo;
  HistoryCubit(this.repo) : super(HistoryState());

  Future<void> loadEssay() async {
    emit(state.copyWith(loading: true));
    final list = await repo.loadEssayHistory();
    emit(state.copyWith(essay: list, loading: false));
  }

  Future<void> loadInterview() async {
    emit(state.copyWith(loading: true));
    final list = await repo.loadInterviewHistory();
    emit(state.copyWith(interview: list, loading: false));
  }
}
