import 'package:equatable/equatable.dart';

abstract class GrammarState extends Equatable {
  const GrammarState();
  @override
  List<Object?> get props => [];
}

class GrammarInitial extends GrammarState {
  const GrammarInitial();
}

class GrammarLoading extends GrammarState {
  const GrammarLoading();
}

class GrammarSuccess extends GrammarState {
  final String feedback;
  const GrammarSuccess(this.feedback);
  @override
  List<Object?> get props => [feedback];
}

class GrammarFailure extends GrammarState {
  final String message;
  const GrammarFailure(this.message);
  @override
  List<Object?> get props => [message];
}
