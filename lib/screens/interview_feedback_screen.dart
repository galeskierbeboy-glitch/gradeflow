import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pdf_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/glass_card.dart';

class InterviewFeedbackScreen extends StatelessWidget {
  final String niche;
  final String mode;
  final List<Map<String, String>> qna;
  final String feedback;

  const InterviewFeedbackScreen({
    super.key,
    required this.niche,
    required this.mode,
    required this.qna,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Interview Feedback',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interview Details',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Niche: $niche', style: const TextStyle(fontSize: 15, color: Colors.white70)),
                    Text('Mode: $mode', style: const TextStyle(fontSize: 15, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Feedback',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        height: 1.7,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Export as PDF',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () {
                  PdfService().generateReport({
                    'feedback': feedback,
                    'overall_score': 'N/A',
                    'overall_summary': feedback,
                    'feedback_categories': <String, dynamic>{},
                    'suggested_improvements': <String>[],
                    'answer_feedback': <dynamic>[],
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
