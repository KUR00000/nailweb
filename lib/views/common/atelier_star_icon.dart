import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Mathematically drawn 4-pointed luxury faceted atelier star icon.
/// Pure vector path with smooth bezier curves and a center micro-facet highlight.
/// Completely eliminates unicode text glyph fallbacks.
class AtelierStarIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AtelierStarIcon({
    super.key,
    this.size = 18,
    this.color = AppTheme.goldAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AtelierStarPainter(color: color),
    );
  }
}

class _AtelierStarPainter extends CustomPainter {
  final Color color;

  _AtelierStarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 4-pointed concave luxury star path
    final path = Path();
    path.moveTo(cx, 0); // top tip
    path.quadraticBezierTo(cx, cy * 0.76, w, cy); // curve to right tip
    path.quadraticBezierTo(cx * 1.24, cy, cx, h); // curve to bottom tip
    path.quadraticBezierTo(cx, cy * 1.24, 0, cy); // curve to left tip
    path.quadraticBezierTo(cx * 0.76, cy, cx, 0); // curve back to top tip
    path.close();

    canvas.drawPath(path, paint);

    // Subtle micro diamond highlight in center for optical luxury depth
    if (size.width >= 12) {
      final centerHighlight = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final innerPath = Path();
      final s = w * 0.16;
      innerPath.moveTo(cx, cy - s);
      innerPath.lineTo(cx + s, cy);
      innerPath.lineTo(cx, cy + s);
      innerPath.lineTo(cx - s, cy);
      innerPath.close();
      canvas.drawPath(innerPath, centerHighlight);
    }
  }

  @override
  bool shouldRepaint(covariant _AtelierStarPainter oldDelegate) => oldDelegate.color != color;
}
