import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pdf_service.dart';
import '../widgets/primary_button.dart';

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
    return Scaffold(
      appBar: AppBar(
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
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interview Details',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Niche: $niche', style: const TextStyle(fontSize: 15)),
                    Text('Mode: $mode', style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Questions & Answers',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...qna.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${idx + 1}: ${item['question'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A: ${item['answer'] ?? '(No answer provided)'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'AI Feedback',
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feedback,
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        height: 1.7,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
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
    );
  }
}
