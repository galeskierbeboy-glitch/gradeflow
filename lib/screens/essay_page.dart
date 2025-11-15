import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/feedback_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:io' show File;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:file_selector/file_selector.dart';
// image OCR via google_ml_kit removed for now (platform setup required)
import 'package:flutter/foundation.dart' show kIsWeb;

class EssayPage extends StatefulWidget {
  const EssayPage({super.key});

  @override
  State<EssayPage> createState() => _EssayPageState();
}

// Painter that draws four L-shaped corner brackets around a rect
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double length;

  _CornerBracketsPainter({
    required this.color,
    this.strokeWidth = 2,
    this.length = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    // Top-left
    canvas.drawLine(Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, length), paint);

    // Top-right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - length, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - length),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - length, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.length != length;
  }
}

class _EssayPageState extends State<EssayPage> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();

  String _feedback = '';
  bool _isLoading = false;

  Future<void> _getFeedback() async {
    final essay = _controller.text.trim();
    if (essay.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final feedback = await _aiService.getEssayFeedback(essay);

      if (!mounted) return;
      setState(() {
        _feedback = feedback;
        _isLoading = false;
      });

      _showFeedbackBottomSheet(feedback);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // -------------------------
  // File upload & extraction
  // -------------------------
  Future<void> _pickFile() async {
    // Allow PDF and common image types using file_selector (cross-platform)
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

      // Web: file_selector may return bytes; we won't attempt extraction in web builds here
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
        // Try rendering first page of PDF and run OCR on it.
        await _processPdf(file);
      } else {
        await _processImage(file);
      }
    } catch (e) {
      debugPrint('File pick error: $e');
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
      // Put extracted text into editor so user can edit/confirm before sending to AI
      _controller.text = extracted;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image OCR complete — text placed into editor.'),
        ),
      );
    } catch (e) {
      debugPrint('OCR error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image OCR failed: $e')));
    }
  }

  Future<void> _processPdf(File file) async {
    // PDF extraction via rendering + OCR is not enabled in this build.
    // For now, ask the user to paste text or convert to an image and upload.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'PDF extraction is not available in this build. Please copy/paste the essay text or upload an image of the PDF page.',
        ),
      ),
    );
  }

  // (Removed unused essay-detection heuristic; keep upload UI simple.)

  void _showFeedbackBottomSheet(String feedback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 38, 39, 37),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Text(
                'AI Essay Feedback',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    feedback,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      height: 1.7,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 20),
            ],
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
                Color.fromARGB(255, 35, 37, 38), // #232526
                Color.fromARGB(255, 65, 67, 69), // #414345
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextField
              TextField(
                controller: _controller,
                maxLines: 8,
                style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16),
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
                  fillColor: Colors.white.withValues(alpha: 0.08),
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
                    borderSide: const BorderSide(color: Colors.cyan, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload PDF/Image
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload PDF / Image'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _isLoading ? null : _pickFile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Submit Button (activation style)
              _ActivationButton(
                onPressed: _isLoading ? null : _getFeedback,
                isLoading: _isLoading,
                label: 'Generate Feedback',
              ),
              const SizedBox(height: 28),

              // Loading / Feedback
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: Lottie.asset(
                          'assets/ai_animation.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analyzing your essay...',
                        style: GoogleFonts.urbanist(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_feedback.isNotEmpty)
                Expanded(
                  child: FeedbackCard(
                    feedback: _feedback,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.7,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Activation-style rectangular button with animated corner brackets
class _ActivationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const _ActivationButton({
    this.onPressed,
    this.isLoading = false,
    required this.label,
  });

  @override
  State<_ActivationButton> createState() => _ActivationButtonState();
}

class _ActivationButtonState extends State<_ActivationButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _anim;
  Animation<double>? _scale;
  Animation<Color?>? _bgColor;
  Animation<Color?>? _fgColor;
  Animation<Color?>? _borderColor;
  Animation<double>? _cornerOpacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.easeOutCubic));
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.black,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.ease));
    _fgColor = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.ease));
    _borderColor = ColorTween(
      begin: Colors.black,
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.ease));
    _cornerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim!, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _anim?.forward(),
      onExit: (_) => _anim?.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => _anim?.forward(),
        onTapUp: (_) => _anim?.reverse(),
        onTapCancel: () => _anim?.reverse(),
        child: AnimatedBuilder(
          animation: _anim ?? AlwaysStoppedAnimation<double>(0.0),
          builder: (_, __) {
            return Transform.scale(
              scale: _scale?.value ?? 1.0,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _bgColor?.value ?? Colors.white,
                        border: Border.all(
                          color: _borderColor?.value ?? Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),

                    Opacity(
                      opacity: _cornerOpacity?.value ?? 0.0,
                      child: CustomPaint(
                        size: Size(double.infinity, 56),
                        painter: _CornerBracketsPainter(
                          color: (_fgColor?.value ?? Colors.white).withAlpha(
                            ((_cornerOpacity?.value ?? 0.0) * 255).round(),
                          ),
                          strokeWidth: 3,
                          length: 18,
                        ),
                      ),
                    ),

                    Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_fix_high, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  widget.label,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _fgColor?.value ?? Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
