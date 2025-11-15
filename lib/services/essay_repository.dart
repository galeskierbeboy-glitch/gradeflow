import 'ai_service.dart';

abstract class EssayRepository {
  Future<String> getEssayFeedback(String essayText);
}

class EssayRepositoryImpl implements EssayRepository {
  final AIService _ai;
  EssayRepositoryImpl(this._ai);

  @override
  Future<String> getEssayFeedback(String essayText) {
    return _ai.getEssayFeedback(essayText);
  }
}
