import 'ai_service.dart';

abstract class InterviewRepository {
  Future<List<String>> generateInterviewQuestions({
    required String mode,
    required String niche,
  });

  Future<String> getInterviewFeedback({
    required String niche,
    required List<Map<String, String>> qna,
  });
}

class InterviewRepositoryImpl implements InterviewRepository {
  final AIService _ai;
  InterviewRepositoryImpl(this._ai);

  @override
  Future<List<String>> generateInterviewQuestions({
    required String mode,
    required String niche,
  }) {
    return _ai.generateInterviewQuestions(mode: mode, niche: niche);
  }

  @override
  Future<String> getInterviewFeedback({
    required String niche,
    required List<Map<String, String>> qna,
  }) {
    return _ai.getInterviewFeedback(niche: niche, qna: qna);
  }
}
