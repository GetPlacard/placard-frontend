import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImageUtils {
  static Future<ui.Image> convertUint8ListToImage(bytes) async {
    final imageCodec = await ui.instantiateImageCodec(bytes);

    final nextFrame = await imageCodec.getNextFrame();

    return nextFrame.image;
  }

  static Future<ui.Image> clipImageToRRect(
      ui.Image inputImage, double width, double height, double radius) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    canvas.clipRRect(
      RRect.fromLTRBR(
        0,
        0,
        width,
        height,
        Radius.circular(radius),
      ),
    );

    canvas.scale(
      width / inputImage.width,
      height / inputImage.height,
    );

    canvas.drawImage(
      inputImage,
      Offset(0, 0),
      Paint(),
    );

    final outputImage = await pictureRecorder.endRecording().toImage(
          width.toInt(),
          height.toInt(),
        );

    return outputImage;
  }

  // https://stackoverflow.com/a/55050020/8005366
  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
