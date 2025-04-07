import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextBoundingBoxPainter extends CustomPainter {
  final List<TextBlock> textBlocks;
  final List<int> imageRes;
  final double constraintWidth;
  final Rect priceTagBox;

  TextBoundingBoxPainter(
      this.priceTagBox, this.textBlocks, this.imageRes, this.constraintWidth);

  @override
  // Flutter automatically calls paint
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double ratio = imageRes[1] / constraintWidth;

    for (var block in textBlocks) {
      // boundingBox is type of rect
      // Image is 320 x 500
      // File Image is 3000 x 4000
      // double ratioWidth = imageRes[1] / constraintWidth;
      // double ratioHeight = ratioWidth;
      double left = block.boundingBox.left / ratio;
      double top = block.boundingBox.top / ratio;
      double right = block.boundingBox.right / ratio;
      double bottom = block.boundingBox.bottom / ratio;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
    // Convert 375 x 375  to  360 x 360
    double leftPriceTag = 2 * priceTagBox.left / ratio;
    double topPriceTag = 2 * priceTagBox.top / ratio;
    double rightPriceTag = 2 * priceTagBox.right / ratio;
    double bottomPriceTag = 2 * priceTagBox.bottom / ratio;
    canvas.drawRect(
        Rect.fromLTRB(leftPriceTag, topPriceTag, rightPriceTag, bottomPriceTag),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
