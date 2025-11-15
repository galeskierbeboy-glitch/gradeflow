import 'package:equatable/equatable.dart';

class InterviewState extends Equatable {
  final String selectedNiche;
  final String selectedMode;
  final List<String> questions;
  final int questionIndex;
  final List<String> givenAnswers;
  final bool isGenerating;
  final bool isLoadingFeedback;
  final bool isListening;
  final int remainingTime;
  final String? feedback; // human-readable feedback string
  final String? error;

  const InterviewState({
    this.selectedNiche = 'Banking',
    this.selectedMode = 'Mock Interview',
    this.questions = const [],
    this.questionIndex = 0,
    this.givenAnswers = const [],
    this.isGenerating = false,
    this.isLoadingFeedback = false,
    this.isListening = false,
    this.remainingTime = 60,
    this.feedback,
    this.error,
  });

  bool get isLast => questionIndex >= questions.length;
  String? get currentQuestion =>
      isLast ? null : (questions.isNotEmpty ? questions[questionIndex] : null);

  InterviewState copyWith({
    String? selectedNiche,
    String? selectedMode,
    List<String>? questions,
    int? questionIndex,
    List<String>? givenAnswers,
    bool? isGenerating,
    bool? isLoadingFeedback,
    bool? isListening,
    int? remainingTime,
    String? feedback,
    String? error,
    bool clearFeedback = false,
    bool clearError = false,
  }) {
    return InterviewState(
      selectedNiche: selectedNiche ?? this.selectedNiche,
      selectedMode: selectedMode ?? this.selectedMode,
      questions: questions ?? this.questions,
      questionIndex: questionIndex ?? this.questionIndex,
      givenAnswers: givenAnswers ?? this.givenAnswers,
      isGenerating: isGenerating ?? this.isGenerating,
      isLoadingFeedback: isLoadingFeedback ?? this.isLoadingFeedback,
      isListening: isListening ?? this.isListening,
      remainingTime: remainingTime ?? this.remainingTime,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    selectedNiche,
    selectedMode,
    questions,
    questionIndex,
    givenAnswers,
    isGenerating,
    isLoadingFeedback,
    isListening,
    remainingTime,
    feedback,
    error,
  ];
}
