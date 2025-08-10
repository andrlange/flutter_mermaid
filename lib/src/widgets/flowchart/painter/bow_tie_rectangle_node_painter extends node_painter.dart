import 'node_painter.dart';

class BowTieRectangleNodePainter extends NodePainter {
  const BowTieRectangleNodePainter({
    required super.style,
    required super.scaleFactor,
    this.curveDepth = 15.0, // Wie weit die Rundung raus/rein geht
  });

  /// Positiver Wert: größere Auswölbung / Einbuchtung
  final double curveDepth;

  @override
  void drawShape(Canvas canvas, Size size) {
    final inset = style.borderWidth / 2;

    final path = Path();

    // Start oben links
    path.moveTo(inset, inset);

    // Oben gerade Linie
    path.lineTo(size.width - inset, inset);

    // Rechte Seite: flache konkave Rundung
    path.quadraticBezierTo(
      size.width + inset - curveDepth, // Steuerpunkt leicht rechts raus
      size.height / 2, // Mitte
      size.width - inset, // Endpunkt unten rechts
      size.height - inset, // unten rechts
    );

    // Unten gerade Linie zurück
    path.lineTo(inset, size.height - inset);

    // Linke Seite: flache konvexe Rundung
    path.quadraticBezierTo(
      inset - curveDepth, // Steuerpunkt leicht links rein
      size.height / 2, // Mitte
      inset, // Endpunkt oben links
      inset, // zurück zum Start
    );

    path.close();

    // Hintergrund
    canvas.drawPath(path, createBackgroundPaint());

    // Rand
    drawDashedPath(canvas, path, createBorderPaint());
  }
}
