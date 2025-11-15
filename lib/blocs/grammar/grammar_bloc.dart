import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/essay_repository.dart';
import 'grammar_event.dart';
import 'grammar_state.dart';

class GrammarBloc extends Bloc<GrammarEvent, GrammarState> {
  final EssayRepository repository;
  GrammarBloc({required this.repository}) : super(const GrammarInitial()) {
    on<GrammarSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    GrammarSubmitted event,
    Emitter<GrammarState> emit,
  ) async {
    final text = event.essay.trim();
    if (text.isEmpty) return;
    emit(const GrammarLoading());
    try {
      final feedback = await repository.getEssayFeedback(text);
      emit(GrammarSuccess(feedback));
    } catch (e) {
      emit(GrammarFailure('Error generating feedback: $e'));
    }
  }
}
