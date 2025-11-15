import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ──────────────────────────────────────────────────────────────────────
  //  Colors (no withOpacity → withAlpha)
  // ──────────────────────────────────────────────────────────────────────
  static const _bgStart = Color(0xFF232526); // #232526
  static const _bgEnd = Color(0xFF414345); // #414345
  static const _primary = Color(0xFF00D9FF); // electric cyan

  static Color _glow(double alpha) => _primary.withAlpha((255 * alpha).round());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgStart, _bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            _GlowParticles(size: size),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 24),

                  // Logo and title block (top / middle)
                  Column(
                    children: [
                      _NeonLogo(),
                      const SizedBox(height: 24),
                      Text(
                        "WELCOME",
                        style: GoogleFonts.rampartOne(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "TO",
                        style: GoogleFonts.rampartOne(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "GRADEFLOW",
                        style: GoogleFonts.rampartOne(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Your personal AI essay feedback assistant",
                        style: GoogleFonts.majorMonoDisplay(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 0.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  // Buttons at bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 260,
                          child: _TechnoButton(
                            label: "Essay Assistant",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/essay'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 260,
                          child: _TechnoButton(
                            label: "Interview Prep",
                            onPressed: () =>
                                Navigator.pushNamed(context, '/interview'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//  SUBTLE GLOWING PARTICLES
// ──────────────────────────────────────────────────────────────────────
class _GlowParticles extends StatelessWidget {
  const _GlowParticles({required this.size});
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(10, (i) {
          final left = (i % 4) * size.width / 4 + (i * 29) % 100;
          final top = (i ~/ 4) * size.height / 3 + (i * 41) % 120;
          return _Particle(left: left, top: top);
        }),
      ),
    );
  }
}

class _Particle extends StatelessWidget {
  const _Particle({required this.left, required this.top});
  final double left, top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 3),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeInOut,
        builder: (_, value, __) {
          return Transform.scale(
            scale: 0.5 + value * 0.5,
            child: Opacity(
              opacity: 0.3 - value * 0.15,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HomePage._primary,
                  boxShadow: [
                    BoxShadow(
                      color: HomePage._glow(0.5 * value),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//  LOGO + PULSING NEON RING
// ──────────────────────────────────────────────────────────────────────
class _NeonLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (_, value, __) {
            return Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HomePage._primary.withAlpha(0),
                    HomePage._glow(0.3 * value),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: HomePage._glow(0.5 * value),
                    blurRadius: 28,
                    spreadRadius: 10,
                  ),
                ],
              ),
            );
          },
        ),
        Lottie.asset(
          'assets/ideoo_g_icon.json',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
//  TECHNO BUTTON – NOW WITH CUSTOM LABEL
// ──────────────────────────────────────────────────────────────────────
class _TechnoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _TechnoButton({required this.onPressed, required this.label});

  @override
  State<_TechnoButton> createState() => _TechnoButtonState();
}

class _TechnoButtonState extends State<_TechnoButton>
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
          animation: _anim ?? AlwaysStoppedAnimation(0),
          builder: (_, __) {
            return Transform.scale(
              scale: _scale?.value ?? 1.0,
              child: SizedBox(
                width: 260,
                height: 60,
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
                        size: const Size(260, 60),
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
                      child: Text(
                        widget.label, // ← THIS IS YOUR TEXT
                        style: GoogleFonts.oxanium(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _fgColor?.value ?? Colors.black,
                          letterSpacing: 1.2,
                        ),
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

    canvas.drawLine(Offset(0, 0), Offset(length, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, length), paint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - length, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - length),
      paint,
    );
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
