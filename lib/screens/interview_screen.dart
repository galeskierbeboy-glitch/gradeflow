import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../widgets/gradient_background.dart';
import '../widgets/loading_view.dart';
import '../widgets/interview_controls.dart';
import '../widgets/interview_content.dart';
import '../widgets/section_card.dart';
import '../blocs/interview/interview_bloc.dart';
import '../blocs/interview/interview_event.dart';
import '../blocs/interview/interview_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../services/history_repository.dart';
import 'interview_feedback_screen.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerController = TextEditingController();
  late stt.SpeechToText _speech;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<InterviewBloc>();
      if (bloc.state.questions.isEmpty && !bloc.state.isGenerating) {
        bloc.add(const InterviewStarted());
      }
    });
  }

  Future<void> _saveAnswerAndNext() async {
    final answer = _answerController.text.trim();
    final bloc = context.read<InterviewBloc>();
    if (answer.isNotEmpty && !bloc.state.isLast) {
      bloc.add(InterviewAnswerSubmitted(answer));
    }
    _answerController.clear();
    bloc.add(const InterviewNextQuestion());
  }

  Future<void> _finishAndGetFeedback() async {
    final answer = _answerController.text.trim();
    final bloc = context.read<InterviewBloc>();
    if (answer.isNotEmpty && !bloc.state.isLast) {
      bloc.add(InterviewAnswerSubmitted(answer));
      _answerController.clear();
    }
    bloc.add(const InterviewFinishRequested());
  }

  //

  Future<void> _toggleListening() async {
    if (!_isListening) {
      final status = await Permission.microphone.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
        return;
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission permanently denied. Please enable it in settings.',
              ),
            ),
          );
        }
        openAppSettings();
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') setState(() => _isListening = false);
        },
        onError: (error) => debugPrint('Speech error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              final currentWords = result.recognizedWords;
              if (result.finalResult) {
                if (_answerController.text.isEmpty) {
                  _answerController.text = currentWords;
                } else {
                  _answerController.text =
                      '${_answerController.text} $currentWords';
                }
              }
            });
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.dictation,
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "InterviewPrep: AI Interview Coach",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Theme',
              icon: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Colors.white,
                  );
                },
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
            IconButton(
              tooltip: 'History',
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () async {
                final items = await HistoryRepository().loadInterviewHistory();
                if (!mounted) return;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  builder: (ctx) => DraggableScrollableSheet(
                    initialChildSize: 0.85,
                    maxChildSize: 0.95,
                    minChildSize: 0.5,
                    expand: false,
                    builder: (_, scroll) => ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final e = items[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          tileColor: Colors.grey.shade100,
                          title: Text(
                            '${e['niche']} • ${e['mode']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            (e['feedback'] as String? ?? '').trim(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            (e['timestamp'] as String? ?? '').split('T').first,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<InterviewBloc, InterviewState>(
            listenWhen: (prev, curr) =>
                prev.questionIndex != curr.questionIndex ||
                prev.feedback != curr.feedback,
            listener: (context, state) {
              if (state.feedback != null) {
                // Save history entry
                final qna = <Map<String, String>>[];
                for (var i = 0; i < state.questions.length; i++) {
                  qna.add({
                    'question': state.questions[i],
                    'answer': i < state.givenAnswers.length
                        ? state.givenAnswers[i]
                        : '',
                  });
                }
                HistoryRepository().addInterviewEntry(
                  niche: state.selectedNiche,
                  mode: state.selectedMode,
                  qna: qna,
                  feedback: state.feedback!,
                );
                // Navigate to feedback screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterviewFeedbackScreen(
                      niche: state.selectedNiche,
                      mode: state.selectedMode,
                      qna: qna,
                      feedback: state.feedback!,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.isGenerating) {
                return const LoadingView(
                  message: "Generating AI interview questions...",
                );
              }
              final questions = state.questions;
              final isLast = state.isLast;
              final currentQuestion = state.currentQuestion;
              final nicheKeys = const [
                'Banking',
                'Tech Job',
                'School Admission',
                'Customer Service',
              ];
              final modeKeys = const [
                'Mock Interview',
                'Rapid Fire',
                'Deep Dive',
              ];

              return SingleChildScrollView(
                key: const ValueKey('content'),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterviewControls(
                      selectedNiche: state.selectedNiche,
                      nicheKeys: nicheKeys,
                      selectedMode: state.selectedMode,
                      modeKeys: modeKeys,
                      onNicheChanged: (v) {
                        if (v == null) return;
                        context.read<InterviewBloc>().add(
                          InterviewNicheChanged(v),
                        );
                      },
                      onModeChanged: (v) {
                        if (v == null) return;
                        context.read<InterviewBloc>().add(
                          InterviewModeChanged(v),
                        );
                      },
                      onRestart: () => context.read<InterviewBloc>().add(
                        const InterviewStarted(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    InterviewContent(
                      isLast: isLast,
                      isLoading: state.isLoadingFeedback,
                      questionIndex: state.questionIndex,
                      totalQuestions: questions.length,
                      currentQuestion: currentQuestion,
                      answerController: _answerController,
                      isListening: _isListening,
                      onFinish: _finishAndGetFeedback,
                      onNext: _saveAnswerAndNext,
                      mode: state.selectedMode,
                      remainingTime: state.remainingTime,
                      onToggleListening: _toggleListening,
                    ),

                    // Loading section (not on the button)
                    if (state.isLoadingFeedback)
                      const SectionCard(
                        header: Text(
                          'Generating Interview Feedback...',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
