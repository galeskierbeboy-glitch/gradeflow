import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Painter that draws four L-shaped corner brackets around a rect
class CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double length;

  CornerBracketsPainter({
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
    canvas.drawLine(const Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, length), paint);

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
  bool shouldRepaint(covariant CornerBracketsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.length != length;
  }
}

// Activation-style rectangular button with animated corner brackets
class ActivationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final IconData? icon;

  const ActivationButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    required this.label,
    this.icon,
  });

  @override
  State<ActivationButton> createState() => _ActivationButtonState();
}

class _ActivationButtonState extends State<ActivationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;
  late final Animation<Color?> _bgColor;
  late final Animation<Color?> _fgColor;
  late final Animation<Color?> _borderColor;
  late final Animation<double> _cornerOpacity;

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
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _bgColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.black,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.ease));
    _fgColor = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.ease));
    _borderColor = ColorTween(
      begin: Colors.black,
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.ease));
    _cornerOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _anim.forward(),
      onExit: (_) => _anim.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => _anim.forward(),
        onTapUp: (_) => _anim.reverse(),
        onTapCancel: () => _anim.reverse(),
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) {
            return Transform.scale(
              scale: _scale.value,
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
                        color: _bgColor.value,
                        border: Border.all(
                          color: _borderColor.value ?? Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: _cornerOpacity.value,
                      child: CustomPaint(
                        size: const Size(double.infinity, 56),
                        painter: CornerBracketsPainter(
                          color: (_fgColor.value ?? Colors.white).withAlpha(
                            (_cornerOpacity.value * 255).round(),
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
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    size: 20,
                                    color: _fgColor.value,
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Text(
                                  widget.label,
                                  style: GoogleFonts.urbanist(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: _fgColor.value,
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
