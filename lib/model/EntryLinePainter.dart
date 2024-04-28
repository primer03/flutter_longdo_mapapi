import 'dart:math';
import 'package:flutter/material.dart';

class EntryLinePainter extends CustomPainter {
  final int index;
  final int length;

  EntryLinePainter(this.index, this.length);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    print("custom painter");

    // Existing line drawing code remains unchanged
    if (index != 0) {
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, -38), paint);
      drawDottedLine(canvas, Offset(2, 0), Offset(2, size.height / 2),
          paint); // Draw a dotted line
    }
    if (index != length - 1) {
      final paintx = Paint()
        ..color = Colors.green.shade700
        ..strokeWidth = 2;
      drawDottedLine(
          canvas, Offset(2, size.height / 2), Offset(2, size.height), paint);
      // canvas.drawLine(Offset(-38, size.height / 2), Offset(-38, 60.0), paint);
    }
    drawDottedLine(canvas, Offset(0, size.height / 2),
        Offset(50, size.height / 2), paint); // Draw a dotted line
    // canvas.drawLine(
    //     Offset(20, size.height / 2), Offset(40, size.height / 2), paint);

    // White background circle
    final paintCircleWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(2, size.height / 2), 10, paintCircleWhite);

    // Red border circle
    final paintCircleRed = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Adjust the border thickness here
    canvas.drawCircle(Offset(2, size.height / 2), 10, paintCircleRed);
  }

  void drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dotSize = 5.0; // Size of each dot
    const double space = 5.0; // Space between dots

    double dx = end.dx - start.dx;
    double dy = end.dy - start.dy;
    double distance = sqrt(dx * dx + dy * dy);
    double intervalLength = dotSize + space;

    // Calculate the number of dots
    int numDots = (distance / intervalLength).floor();

    for (int i = 0; i < numDots; i++) {
      // Calculate the x and y coordinates for each dot
      double x = start.dx + (dx / distance) * intervalLength * i;
      double y = start.dy + (dy / distance) * intervalLength * i;
      canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
