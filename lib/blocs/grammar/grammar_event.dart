import 'package:equatable/equatable.dart';

abstract class GrammarEvent extends Equatable {
  const GrammarEvent();
  @override
  List<Object?> get props => [];
}

class GrammarSubmitted extends GrammarEvent {
  final String essay;
  const GrammarSubmitted(this.essay);
  @override
  List<Object?> get props => [essay];
}
