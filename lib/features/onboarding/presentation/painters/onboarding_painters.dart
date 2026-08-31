import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Draws a soft drop-shadow under any shape without the Elevation widget.
void _drawShadow(
  Canvas canvas,
  Path path, {
  double blur = 12,
  double dy = 4,
  Color color = const Color(0x22000000),
}) {
  canvas.drawShadow(path, color, blur, false);
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1 — Globe with speech bubbles ("AI calls in any language")
// ─────────────────────────────────────────────────────────────────────────────
class GlobeLanguagePainter extends CustomPainter {
  const GlobeLanguagePainter({required this.progress});
  final double progress; // 0.0 → 1.0 animation

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Background circle (very light green) ─────────────────────────────
    final bgPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, bgPaint);

    // ── Globe body ────────────────────────────────────────────────────────
    final globeR = size.width * 0.28;
    final globeCenter = Offset(cx, cy + size.height * 0.02);

    final globeFill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.0,
        colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
      ).createShader(
        Rect.fromCircle(center: globeCenter, radius: globeR),
      );
    canvas.drawCircle(globeCenter, globeR, globeFill);

    // ── Globe grid lines (latitude + longitude) ───────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: globeCenter, radius: globeR)));

    // Horizontal parallels
    for (final frac in [-0.55, -0.25, 0.0, 0.25, 0.55]) {
      final y = globeCenter.dy + frac * globeR * 2;
      final halfW =
          math.sqrt(math.max(0, globeR * globeR - (y - globeCenter.dy) * (y - globeCenter.dy)));
      canvas.drawLine(
        Offset(globeCenter.dx - halfW, y),
        Offset(globeCenter.dx + halfW, y),
        gridPaint,
      );
    }

    // Vertical meridians (drawn as ellipses)
    for (final scaleX in [0.35, 0.7, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: globeCenter,
          width: globeR * 2 * scaleX,
          height: globeR * 2,
        ),
        gridPaint,
      );
    }
    canvas.restore();

    // Globe rim
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(globeCenter, globeR, rimPaint);

    // ── Speech bubbles ────────────────────────────────────────────────────
    _drawSpeechBubble(
      canvas,
      center: Offset(cx - size.width * 0.30, cy - size.height * 0.26),
      label: 'FR',
      color: const Color(0xFF16A34A),
      scale: 0.85 + 0.15 * progress,
    );
    _drawSpeechBubble(
      canvas,
      center: Offset(cx + size.width * 0.30, cy - size.height * 0.14),
      label: 'AR',
      color: const Color(0xFF0369A1),
      scale: 0.9 + 0.1 * progress,
    );
    _drawSpeechBubble(
      canvas,
      center: Offset(cx + size.width * 0.26, cy + size.height * 0.28),
      label: 'EN',
      color: const Color(0xFF16A34A),
      scale: 0.8 + 0.2 * progress,
    );
    _drawSpeechBubble(
      canvas,
      center: Offset(cx - size.width * 0.28, cy + size.height * 0.24),
      label: 'SW',
      color: const Color(0xFF0369A1),
      scale: 0.88 + 0.12 * progress,
    );

    // ── Sound-wave arcs emanating from globe ─────────────────────────────
    final wavePaint = Paint()
      ..color = const Color(0xFF16A34A).withValues(alpha: 0.18 + 0.12 * progress)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final r = globeR + i * size.width * 0.055 + progress * size.width * 0.01;
      canvas.drawArc(
        Rect.fromCircle(center: globeCenter, radius: r),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        wavePaint,
      );
    }
  }

  void _drawSpeechBubble(
    Canvas canvas, {
    required Offset center,
    required String label,
    required Color color,
    required double scale,
  }) {
    final bW = 44.0 * scale;
    final bH = 30.0 * scale;
    final br = 10.0 * scale;
    final tailH = 8.0 * scale;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: bW, height: bH),
      Radius.circular(br),
    );

    final bubblePath = Path()..addRRect(rect);
    _drawShadow(canvas, bubblePath);

    canvas.drawRRect(rect, Paint()..color = color);

    // Tail
    final tailPath = Path()
      ..moveTo(center.dx - 6 * scale, center.dy + bH / 2)
      ..lineTo(center.dx, center.dy + bH / 2 + tailH)
      ..lineTo(center.dx + 6 * scale, center.dy + bH / 2)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = color);

    // Label text
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.0 * scale,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(GlobeLanguagePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2 — Voice waveform with mic ("Your voice, your words")
// ─────────────────────────────────────────────────────────────────────────────
class VoiceWavePainter extends CustomPainter {
  const VoiceWavePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Background pill ───────────────────────────────────────────────────
    final bgPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy),
            width: size.width * 0.84,
            height: size.height * 0.72),
        const Radius.circular(40),
      ),
      bgPaint,
    );

    // ── Waveform bars ─────────────────────────────────────────────────────
    const barCount = 28;
    final barW = size.width * 0.018;
    final spacing = size.width * 0.026;
    final totalW = barCount * (barW + spacing) - spacing;
    final startX = cx - totalW / 2;
    final waveY = cy + size.height * 0.10;

    // Heights follow a voice-like amplitude profile
    final amplitudes = <double>[
      0.15, 0.30, 0.55, 0.80, 0.95, 0.70, 0.85, 0.60,
      0.40, 0.75, 1.00, 0.85, 0.65, 0.50, 0.65, 0.85,
      1.00, 0.75, 0.40, 0.60, 0.85, 0.70, 0.95, 0.80,
      0.55, 0.30, 0.20, 0.10,
    ];

    for (int i = 0; i < barCount; i++) {
      final amp = amplitudes[i];
      final phaseShift = (i / barCount) * math.pi * 2;
      final animated = amp * (0.7 + 0.3 * math.sin(progress * math.pi * 2 + phaseShift));
      final barH = size.height * 0.22 * animated;

      final isCenter = (i - barCount / 2).abs() < barCount * 0.20;
      final color = isCenter
          ? const Color(0xFF16A34A)
          : const Color(0xFF16A34A).withValues(alpha: 0.40);

      final x = startX + i * (barW + spacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barW / 2, waveY),
          width: barW,
          height: barH.clamp(4.0, size.height),
        ),
        Radius.circular(barW / 2),
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }

    // ── Microphone icon ───────────────────────────────────────────────────
    final micCX = cx;
    final micCY = cy - size.height * 0.10;
    final micW = size.width * 0.13;
    final micH = size.height * 0.24;
    final micR = micW / 2;

    // Glow ring behind mic
    final glowPaint = Paint()
      ..color = const Color(0xFF16A34A).withValues(alpha: 0.12 + 0.08 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(micCX, micCY), micW * 1.5, glowPaint);

    // Mic body (rounded rect)
    final micBodyPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(micCX, micCY), width: micW, height: micH),
          Radius.circular(micR),
        ),
      );
    _drawShadow(canvas, micBodyPath);
    canvas.drawPath(
      micBodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
        ).createShader(
          Rect.fromCenter(
              center: Offset(micCX, micCY), width: micW, height: micH),
        ),
    );

    // Mic grille lines
    final grillePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(micCX - micR * 0.55, micCY + i * micH * 0.14),
        Offset(micCX + micR * 0.55, micCY + i * micH * 0.14),
        grillePaint,
      );
    }

    // Stand arc + base
    final standPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final arcR = micW * 1.05;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(micCX, micCY + micH * 0.22),
        width: arcR * 2,
        height: arcR * 1.3,
      ),
      0,
      math.pi,
      false,
      standPaint,
    );

    // Vertical stem
    canvas.drawLine(
      Offset(micCX, micCY + micH * 0.22 + arcR * 0.65),
      Offset(micCX, micCY + micH * 0.22 + arcR * 0.65 + micH * 0.14),
      standPaint,
    );

    // Horizontal base
    canvas.drawLine(
      Offset(micCX - micW * 0.7, micCY + micH * 0.22 + arcR * 0.65 + micH * 0.14),
      Offset(micCX + micW * 0.7, micCY + micH * 0.22 + arcR * 0.65 + micH * 0.14),
      standPaint,
    );

    // ── Small floating language chips ─────────────────────────────────────
    _drawChip(canvas,
        center: Offset(cx - size.width * 0.33, cy - size.height * 0.28),
        label: 'Hausa',
        color: const Color(0xFF16A34A));
    _drawChip(canvas,
        center: Offset(cx + size.width * 0.32, cy - size.height * 0.22),
        label: 'Wolof',
        color: const Color(0xFF0369A1));
    _drawChip(canvas,
        center: Offset(cx + size.width * 0.30, cy + size.height * 0.30),
        label: 'Fulani',
        color: const Color(0xFF16A34A));
  }

  void _drawChip(Canvas canvas,
      {required Offset center,
      required String label,
      required Color color}) {
    const h = 22.0;
    const r = 11.0;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final w = tp.width + 20;
    final chipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        const Radius.circular(r),
      ));
    _drawShadow(canvas, chipPath);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        const Radius.circular(r),
      ),
      Paint()..color = color,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(VoiceWavePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3 — Trial calendar with checkmarks ("7 days free, no card needed")
// ─────────────────────────────────────────────────────────────────────────────
class TrialCalendarPainter extends CustomPainter {
  const TrialCalendarPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Background circle ─────────────────────────────────────────────────
    final bgPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, bgPaint);

    // ── Calendar card ─────────────────────────────────────────────────────
    final cardW = size.width * 0.62;
    final cardH = size.height * 0.54;
    final cardTop = cy - cardH * 0.55;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(cx, cardTop + cardH / 2), width: cardW, height: cardH),
      const Radius.circular(18),
    );

    final cardPath = Path()..addRRect(cardRect);
    _drawShadow(canvas, cardPath, blur: 16, dy: 6);

    // Card body
    canvas.drawRRect(cardRect, Paint()..color = Colors.white);

    // Header bar (green)
    final headerRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
          cx - cardW / 2, cardTop, cardW, cardH * 0.28),
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
    );
    canvas.drawRRect(
      headerRect,
      Paint()
        ..shader = LinearGradient(
          colors: const [Color(0xFF22C55E), Color(0xFF16A34A)],
        ).createShader(Rect.fromLTWH(
            cx - cardW / 2, cardTop, cardW, cardH * 0.28)),
    );

    // "7 DAYS FREE" header text
    final headerCY = cardTop + cardH * 0.14;
    _paintText(canvas, '7 DAYS FREE', Offset(cx, headerCY),
        size: 13, weight: FontWeight.w800, color: Colors.white);

    // Rings on calendar header
    for (final dx in [-cardW * 0.18, cardW * 0.18]) {
      final ringX = cx + dx;
      final ringY = cardTop;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(ringX, ringY), width: 10, height: 18),
          const Radius.circular(3),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }

    // ── Day grid (7 cells) ────────────────────────────────────────────────
    const cols = 7;
    final cellSize = cardW * 0.118;
    final gridStartX = cx - cardW * 0.38;
    final gridY = cardTop + cardH * 0.44;
    final cellSpacing = cardW * 0.055;

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (int i = 0; i < cols; i++) {
      final x = gridStartX + i * (cellSize + cellSpacing) + cellSize / 2;

      // Day letter
      _paintText(canvas, dayLabels[i], Offset(x, gridY - cellSize * 0.9),
          size: 8,
          weight: FontWeight.w600,
          color: const Color(0xFF94A3B8));

      // Cell background
      final isToday = i == 0;
      final isFilled = i < (7 * progress).floor();

      final cellColor = isFilled
          ? const Color(0xFF16A34A)
          : isToday
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFF8FAFC);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(x, gridY), width: cellSize, height: cellSize),
          Radius.circular(cellSize * 0.28),
        ),
        Paint()..color = cellColor,
      );

      // Checkmark on filled days
      if (isFilled) {
        _drawCheckmark(canvas, Offset(x, gridY), cellSize * 0.28);
      } else {
        // Day number
        _paintText(canvas, '${i + 1}', Offset(x, gridY),
            size: 9,
            weight: FontWeight.w600,
            color: const Color(0xFF475569));
      }
    }

    // ── Feature pills below calendar ──────────────────────────────────────
    final pillY1 = cardTop + cardH + size.height * 0.06;
    final pillY2 = pillY1 + size.height * 0.085;

    _drawFeaturePill(canvas,
        center: Offset(cx - cardW * 0.25, pillY1),
        icon: '📞',
        label: '20 calls',
        primary: true);
    _drawFeaturePill(canvas,
        center: Offset(cx + cardW * 0.25, pillY1),
        icon: '✓',
        label: 'Full access',
        primary: false);
    _drawFeaturePill(canvas,
        center: Offset(cx, pillY2),
        icon: '💳',
        label: 'No card needed',
        primary: false);
  }

  void _drawCheckmark(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size * 0.38
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(center.dx - size * 0.55, center.dy)
      ..lineTo(center.dx - size * 0.05, center.dy + size * 0.55)
      ..lineTo(center.dx + size * 0.65, center.dy - size * 0.55);
    canvas.drawPath(path, paint);
  }

  void _drawFeaturePill(
    Canvas canvas, {
    required Offset center,
    required String icon,
    required String label,
    required bool primary,
  }) {
    final color = primary ? const Color(0xFF16A34A) : Colors.white;
    final borderColor = primary ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0);
    const h = 28.0;

    final fullLabel = '$icon  $label';
    final tp = TextPainter(
      text: TextSpan(
        text: fullLabel,
        style: TextStyle(
          color: primary ? Colors.white : const Color(0xFF0F172A),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final w = tp.width + 22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        const Radius.circular(14),
      ),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        const Radius.circular(14),
      ),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintText(Canvas canvas, String text, Offset center,
      {double size = 12,
      FontWeight weight = FontWeight.w500,
      Color color = const Color(0xFF0F172A)}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(fontSize: size, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(TrialCalendarPainter old) => old.progress != progress;
}
