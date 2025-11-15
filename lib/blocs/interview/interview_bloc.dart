import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/interview_repository.dart';
import 'interview_event.dart';
import 'interview_state.dart';

class InterviewBloc extends Bloc<InterviewEvent, InterviewState> {
  final InterviewRepository repository;
  Timer? _timer;

  InterviewBloc({required this.repository}) : super(const InterviewState()) {
    on<InterviewStarted>(_onStarted);
    on<InterviewNicheChanged>(_onNicheChanged);
    on<InterviewModeChanged>(_onModeChanged);
    on<InterviewAnswerSubmitted>(_onAnswerSubmitted);
    on<InterviewNextQuestion>(_onNext);
    on<InterviewFinishRequested>(_onFinish);
    on<InterviewToggleListening>(_onToggleListening);
    on<InterviewTick>(_onTick);
  }

  Future<void> _onStarted(
    InterviewStarted event,
    Emitter<InterviewState> emit,
  ) async {
    final niche = event.niche ?? state.selectedNiche;
    final mode = event.mode ?? state.selectedMode;
    emit(
      state.copyWith(
        isGenerating: true,
        selectedNiche: niche,
        selectedMode: mode,
        questionIndex: 0,
        givenAnswers: const [],
        clearFeedback: true,
        clearError: true,
      ),
    );
    try {
      final questions = await repository.generateInterviewQuestions(
        mode: mode,
        niche: niche,
      );
      // Start timer if Rapid Fire and we have a question
      _stopTimer();
      emit(
        state.copyWith(
          questions: questions,
          isGenerating: false,
          remainingTime: 60,
        ),
      );
      _startTimerIfNeeded();
    } catch (e) {
      emit(
        state.copyWith(
          isGenerating: false,
          error: 'Failed to load questions: $e',
        ),
      );
    }
  }

  Future<void> _onNicheChanged(
    InterviewNicheChanged event,
    Emitter<InterviewState> emit,
  ) async {
    add(InterviewStarted(niche: event.niche));
  }

  Future<void> _onModeChanged(
    InterviewModeChanged event,
    Emitter<InterviewState> emit,
  ) async {
    add(InterviewStarted(mode: event.mode));
  }

  void _onAnswerSubmitted(
    InterviewAnswerSubmitted event,
    Emitter<InterviewState> emit,
  ) {
    final answers = List<String>.from(state.givenAnswers);
    if (state.questionIndex < answers.length) {
      answers[state.questionIndex] = event.answer;
    } else {
      answers.add(event.answer);
    }
    emit(state.copyWith(givenAnswers: answers));
  }

  void _onNext(InterviewNextQuestion event, Emitter<InterviewState> emit) {
    _stopTimer();
    final nextIndex = state.questionIndex + 1;
    emit(state.copyWith(questionIndex: nextIndex, remainingTime: 60));
    _startTimerIfNeeded();
  }

  Future<void> _onFinish(
    InterviewFinishRequested event,
    Emitter<InterviewState> emit,
  ) async {
    if (state.isLoadingFeedback) return;
    _stopTimer();
    emit(state.copyWith(isLoadingFeedback: true, clearFeedback: true));
    try {
      final qna = <Map<String, String>>[];
      for (var i = 0; i < state.questions.length; i++) {
        qna.add({
          'question': state.questions[i],
          'answer': i < state.givenAnswers.length ? state.givenAnswers[i] : '',
        });
      }

      final feedback = await repository.getInterviewFeedback(
        niche: state.selectedNiche,
        qna: qna,
      );
      emit(state.copyWith(isLoadingFeedback: false, feedback: feedback));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingFeedback: false,
          error: 'Failed to generate feedback: $e',
        ),
      );
    }
  }

  void _onToggleListening(
    InterviewToggleListening event,
    Emitter<InterviewState> emit,
  ) {
    emit(state.copyWith(isListening: !state.isListening));
  }

  void _onTick(InterviewTick event, Emitter<InterviewState> emit) {
    if (state.selectedMode != 'Rapid Fire') return;
    final next = state.remainingTime - 1;
    if (next > 0) {
      emit(state.copyWith(remainingTime: next));
    } else {
      // Auto-advance when time runs out
      _stopTimer();
      // Move to next question; UI is responsible for saving any entered answer before this happens
      add(const InterviewNextQuestion());
    }
  }

  void _startTimerIfNeeded() {
    if (state.selectedMode == 'Rapid Fire' && !state.isLast) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const InterviewTick());
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
