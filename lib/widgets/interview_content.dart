import 'package:flutter/material.dart';
import 'glass_card.dart';

class InterviewContent extends StatelessWidget {
  final bool isLast;
  final bool isLoading;
  final int questionIndex;
  final int totalQuestions;
  final String? currentQuestion;
  final TextEditingController answerController;
  final bool isListening;
  final VoidCallback onFinish;
  final VoidCallback onNext;
  final String mode;
  final int remainingTime;
  final VoidCallback onToggleListening;

  const InterviewContent({
    super.key,
    required this.isLast,
    required this.isLoading,
    required this.questionIndex,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.answerController,
    required this.isListening,
    required this.onFinish,
    required this.onNext,
    required this.mode,
    required this.remainingTime,
    required this.onToggleListening,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLast)
              Column(
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Interview Complete! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                onPressed: onFinish,
                color: Colors.deepPurple,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Icon(Icons.star), SizedBox(width: 8), Text('Get AI Feedback')],
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question number and timer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Q${questionIndex + 1}/$totalQuestions",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      "${remainingTime}s",
                      style: TextStyle(
                        fontSize: 14,
                        color: remainingTime <= 10 ? Colors.red : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Question text
              GlassCard(
                borderRadius: 12,
                child: Text(
                  currentQuestion ?? "Loading...",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Mode info
              Text(
                mode,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // Answer text field
              GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: answerController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type or speak your answer...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Voice and submit buttons
              Row(
                children: [
                  GlassButton(
                    onPressed: onToggleListening,
                    color: isListening ? Colors.red : Colors.blueAccent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isListening ? Icons.mic : Icons.mic_none),
                        const SizedBox(width: 8),
                        Text(isListening ? "Listening..." : "Speak"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      onPressed: isLoading ? null : onNext,
                      color: Colors.deepPurple,
                      child: Text(isLoading ? "Submitting..." : "Next"),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
