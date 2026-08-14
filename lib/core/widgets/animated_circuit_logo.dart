import 'package:flutter/material.dart';

class AnimatedCircuitLogo extends StatefulWidget {
  final double size;
  
  const AnimatedCircuitLogo({Key? key, this.size = 100}) : super(key: key);

  @override
  State<AnimatedCircuitLogo> createState() => _AnimatedCircuitLogoState();
}

class _AnimatedCircuitLogoState extends State<AnimatedCircuitLogo> with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _floatController;
  late Animation<double> _drawAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    // Animasi menggambar garis (3 detik)
    _drawController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawController, curve: Curves.easeOutQuart),
    );

    // Animasi mengambang / floating (2 detik bolak-balik)
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _floatAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _drawController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _drawController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_drawController, _floatController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CircuitLogoPainter(_drawAnimation.value),
          ),
        );
      },
    );
  }
}

class CircuitLogoPainter extends CustomPainter {
  final double progress;
  CircuitLogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    canvas.scale(scaleX, scaleY);

    // Gradient sirkuit
    final gradient = const LinearGradient(
      colors: [Color(0xFF00e5ff), Color(0xFF008cff)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    // Paint untuk Neon Glow
    final glowPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Efek neon glow

    // Paint untuk garis utama
    final strokePaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Path Huruf N (M25 80 V20 L75 80 V20)
    final path = Path()
      ..moveTo(25, 80)
      ..lineTo(25, 20)
      ..lineTo(75, 80)
      ..lineTo(75, 20);

    // Animasi path drawing
    if (progress > 0) {
      final pathMetrics = path.computeMetrics().first;
      final extractPath = pathMetrics.extractPath(0.0, pathMetrics.length * progress);
      
      canvas.drawPath(extractPath, glowPaint);
      canvas.drawPath(extractPath, strokePaint);
    }

    // Paint untuk titik (dots) dengan glow
    final dotPaintGlow = Paint()
      ..color = const Color(0xFF00e5ff)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final dotPaint = Paint()
      ..color = const Color(0xFF00e5ff)
      ..style = PaintingStyle.fill;

    void drawGlowingDot(Offset offset, double radius) {
      canvas.drawCircle(offset, radius, dotPaintGlow);
      canvas.drawCircle(offset, radius, dotPaint);
    }

    final dotOpacity = progress < 0.5 ? (progress * 2) : 1.0;
    
    if (dotOpacity > 0) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, 100, 100), Paint()..color = Colors.white.withOpacity(dotOpacity));
      
      drawGlowingDot(const Offset(25, 20), 2.5);
      drawGlowingDot(const Offset(25, 50), 2.0);
      drawGlowingDot(const Offset(25, 80), 2.5);
      drawGlowingDot(const Offset(75, 20), 2.5);
      drawGlowingDot(const Offset(75, 50), 2.0);
      drawGlowingDot(const Offset(75, 80), 2.5);

      // Connecting Nodes (tanpa glow)
      canvas.drawCircle(const Offset(41.7, 40), 1.5, dotPaint);
      canvas.drawCircle(const Offset(58.3, 60), 1.5, dotPaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CircuitLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
