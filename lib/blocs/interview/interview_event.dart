import 'package:equatable/equatable.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();
  @override
  List<Object?> get props => [];
}

class InterviewStarted extends InterviewEvent {
  final String? niche;
  final String? mode;
  const InterviewStarted({this.niche, this.mode});
}

class InterviewNicheChanged extends InterviewEvent {
  final String niche;
  const InterviewNicheChanged(this.niche);
  @override
  List<Object?> get props => [niche];
}

class InterviewModeChanged extends InterviewEvent {
  final String mode;
  const InterviewModeChanged(this.mode);
  @override
  List<Object?> get props => [mode];
}

class InterviewAnswerSubmitted extends InterviewEvent {
  final String answer;
  const InterviewAnswerSubmitted(this.answer);
  @override
  List<Object?> get props => [answer];
}

class InterviewNextQuestion extends InterviewEvent {
  const InterviewNextQuestion();
}

class InterviewFinishRequested extends InterviewEvent {
  const InterviewFinishRequested();
}

class InterviewToggleListening extends InterviewEvent {
  const InterviewToggleListening();
}

class InterviewTick extends InterviewEvent {
  const InterviewTick();
}
