import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_selector/file_selector.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/gradient_background.dart';
import '../services/history_repository.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';
import '../blocs/history/history_cubit.dart';
import '../blocs/grammar/grammar_bloc.dart';
import '../blocs/grammar/grammar_event.dart';
import '../blocs/grammar/grammar_state.dart';
import '../blocs/theme/theme_cubit.dart';
import 'essay_feedback_screen.dart';

class EssayScreen extends StatefulWidget {
  const EssayScreen({super.key});

  @override
  State<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends State<EssayScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _pickFile() async {
    try {
      final XTypeGroup images = XTypeGroup(
        label: 'images',
        extensions: ['png', 'jpg', 'jpeg'],
      );
      final XTypeGroup docs = XTypeGroup(
        label: 'docs',
        extensions: ['pdf', 'txt'],
      );

      final XFile? result = await openFile(acceptedTypeGroups: [docs, images]);
      if (result == null) return;

      if (!mounted) return;

      if (kIsWeb) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File upload available — PDF/image OCR is only supported on mobile/desktop in this build.',
            ),
          ),
        );
        return;
      }

      final path = result.path;
      final file = File(path);
      if (path.toLowerCase().endsWith('.pdf')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF extraction is not available in this build. Please copy/paste the essay text or upload an image of the PDF page.',
            ),
          ),
        );
      } else {
        await _processImage(file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
    }
  }

  Future<void> _processImage(File file) async {
    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognized = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();
      final extracted = recognized.text.trim();
      if (extracted.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No text found in image. Please paste text or try another image.',
            ),
          ),
        );
        return;
      }
      if (!mounted) return;
      _controller.text = extracted;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image OCR complete — text placed into editor.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image OCR failed: $e')));
    }
  }

  void _onGenerate() {
    final essay = _controller.text.trim();
    if (essay.isEmpty) return;
    context.read<GrammarBloc>().add(GrammarSubmitted(essay));
  }

  Future<void> _showHistory() async {
    if (!mounted) return;
    final cubit = context.read<HistoryCubit>();
    await cubit.loadEssay();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 38, 39, 37),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 12,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scroll) => BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = state.essay;
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'No history yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return ListView.separated(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final e = items[i];
                  return InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (dctx) => Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 38, 39, 37),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(dctx).viewInsets.bottom,
                          ),
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.8,
                            maxChildSize: 0.95,
                            minChildSize: 0.5,
                            builder: (_, s) => SingleChildScrollView(
                              controller: s,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionCard(
                                    header: const Text('Essay'),
                                    child: Text(
                                      (e['text'] as String? ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SectionCard(
                                    header: const Text('Feedback'),
                                    child: Text(
                                      (e['feedback'] as String? ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['timestamp'] ?? '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (e['text'] as String? ?? '').trim(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GradeFlow',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            fontSize: 25,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 35, 37, 38),
                Color.fromARGB(255, 65, 67, 69),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black.withAlpha(77),
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
            onPressed: _showHistory,
          ),
        ],
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<GrammarBloc, GrammarState>(
            listenWhen: (prev, curr) => curr is GrammarSuccess,
            listener: (context, state) async {
              if (state is GrammarSuccess) {
                // Save history
                await HistoryRepository().addEssayEntry(
                  text: _controller.text.trim(),
                  feedback: state.feedback,
                );
                // Navigate to feedback screen
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EssayFeedbackScreen(
                      essay: _controller.text.trim(),
                      feedback: state.feedback,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is GrammarLoading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter your essay here',
                      labelStyle: GoogleFonts.urbanist(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      hintText: 'Start writing your essay...',
                      hintStyle: GoogleFonts.urbanist(
                        color: Colors.white38,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white.withAlpha(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.cyan,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Upload PDF / Image',
                    icon: Icons.upload_file,
                    onPressed: isLoading ? null : _pickFile,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Generate Feedback',
                    icon: Icons.auto_fix_high,
                    onPressed: isLoading ? null : _onGenerate,
                  ),
                  const SizedBox(height: 28),
                  if (isLoading)
                    SectionCard(
                      header: const Text('Working…'),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Analyzing your essay...',
                            style: GoogleFonts.urbanist(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
