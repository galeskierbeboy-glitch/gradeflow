import 'package:flutter/material.dart';

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
              ElevatedButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.star),
                label: const Text("Get AI Feedback"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: remainingTime <= 10
                          ? Colors.red.withAlpha(77)
                          : Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: remainingTime <= 10
                            ? Colors.red
                            : Colors.white.withAlpha(77),
                      ),
                    ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(51)),
                ),
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
              TextField(
                controller: answerController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type or speak your answer...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withAlpha(26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(51)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Voice and submit buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: onToggleListening,
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    label: Text(
                      isListening ? "Listening..." : "Speak",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isListening
                          ? Colors.red
                          : Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onNext,
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: Text(
                        isLoading ? "Submitting..." : "Next",
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        disabledBackgroundColor: Colors.deepPurple.withAlpha(
                          128,
                        ),
                      ),
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
