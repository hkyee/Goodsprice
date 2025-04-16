import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
// import 'dart:io';
// import 'package:image/image.dart';

typedef Mat = cv.Mat;

Rect getPriceTagBox(String imagePath) {
  Mat large = cv.imread(imagePath);

// Down samples the image
  Mat rgb = cv.pyrDown(large);

// Converts to gray scale
  Mat small = cv.cvtColor(rgb, cv.COLOR_BGR2GRAY);

  Mat kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));
  Mat grad = cv.morphologyEx(small, cv.MORPH_GRADIENT, kernel);

  var (_, bw) =
      cv.threshold(grad, 0.0, 255.0, cv.THRESH_BINARY | cv.THRESH_OTSU);

  kernel = cv.getStructuringElement(cv.MORPH_RECT, (9, 1));
  Mat connected = cv.morphologyEx(bw, cv.MORPH_CLOSE, kernel);
// using RETR_EXTERNAL instead of RETR_CCOMP
  var (contours, hierarchy) = cv.findContours(
      Mat.fromMat(connected), cv.RETR_EXTERNAL, cv.CHAIN_APPROX_NONE);

// Only 1 channel [0 - 255];
  Mat mask = cv.Mat.zeros(bw.rows, bw.cols, cv.MatType.CV_8UC(1));

// mask = np.zeros(bw.shape, dtype=np.uint8);

// CHeck image res
  // final file = File(imagePath);
  // final bytes = file.readAsBytesSync();
  // final img = decodeImage(bytes);
  // debugPrint("Width : ${img!.width}");
  // debugPrint("Height: ${img!.height}");

  // debugPrint("rgb Width : ${rgb.width}");
  // debugPrint("rgb Height : ${rgb.height}");

// DRAW CONTOURS OF OUTER MOST BOX
  double x1 = (rgb.width / 2);
  double y1 = (rgb.height / 2);
  double x2 = x1;
  double y2 = y1;

  for (int idx = 0; idx < contours.length; idx++) {
    cv.Rect rect = cv.boundingRect(contours[idx]);
    double x = rect.x.toDouble();
    double y = rect.y.toDouble();
    double w = rect.width.toDouble();
    double h = rect.height.toDouble();

    Mat submat = mask.rowRange(y.toInt(), (y + h).toInt());
    submat = submat.colRange(x.toInt(), (x + w).toInt());
    cv.drawContours(mask, contours, idx, cv.Scalar(255, 255, 255),
        thickness: -1);
    // Ratio of white to black
    double r =
        (cv.countNonZero(submat) / (rect.width * rect.height)).toDouble();

    if (r > 0.45 && rect.width > 8 && rect.height > 8) {
      if (x < x1) x1 = x;
      if (y < y1) y1 = y;
      if (x + w > x2) x2 = x + w;
      if (y + h > y2) y2 = y + h;
    }
  }
  // cv.Rect priceTagBox = cv.Rect(x1, y1, x2 - x1, y2 - y1);
  return Rect.fromLTWH(x1, y1, x2 - x1, y2 - y1);
  // cv.rectangle(rgb, priceTagBox, cv.Scalar(0, 0, 255), thickness: 2);

  // cv.imwrite('test.jpg', rgb);
}
