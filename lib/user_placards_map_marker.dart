import 'dart:async';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:placard_frontend/api_manager.dart';
import 'package:placard_frontend/image_utils.dart';

import 'package:placard_frontend/structs/user_placards_map_model.dart';

class UserPlacardsMapMarker {
  static const double imageWidth = 150;
  static const double imageHeight = 100;
  static const double image2OffsetX = 25;
  static const double image2OffsetY = 25;
  static const double imageBorderRadius = 15;
  static const double imageShadowToleranceEstimate = 8;
  static const double fullCanvasWidthEstimate =
      imageWidth + image2OffsetX + shadowRadius + imageShadowToleranceEstimate;
  static const double fullCanvasHeightEstimate =
      imageHeight + image2OffsetY + shadowRadius + imageShadowToleranceEstimate;
  static const double shadowRadius = 7;
  static const double shadowOffsetX = 10;
  static const double shadowOffsetY = 10;
  static const int shadowAlpha = 160;

  UserPlacardsMapMarker(
      this.userPlacardsModel, this._tapCallback, this._apiManager);

  final APIManager _apiManager;

  final UserPlacardsMapModel userPlacardsModel;
  final _tapCallback;
  BitmapDescriptor _image;

  Future<void> updateMarkerImage() async {
    userPlacardsModel.rotatePlacards();
    if (userPlacardsModel.placedPlacardIds.length == 1) {
      final list = await _apiManager
          .getPlacardImage(userPlacardsModel.placedPlacardIds[0]);
      _image = await _renderMarkerIcon(
          image1: await ImageUtils.convertUint8ListToImage(list));
    } else if (userPlacardsModel.placedPlacardIds.length > 1) {
      final list1 = await _apiManager
          .getPlacardImage(userPlacardsModel.placedPlacardIds[0]);
      final list2 = await _apiManager
          .getPlacardImage(userPlacardsModel.placedPlacardIds[1]);
      _image = await _renderMarkerIcon(
        image1: await ImageUtils.convertUint8ListToImage(list1),
        image2: await ImageUtils.convertUint8ListToImage(list2),
      );
    }
  }

  Future<BitmapDescriptor> _renderMarkerIcon({
    ui.Image image1,
    ui.Image image2,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Do image2 first so that image1 goes on top
    if (image2 != null) {
      final resizedImage = await ImageUtils.clipImageToRRect(
        image2,
        imageWidth,
        imageHeight,
        imageBorderRadius,
      );

      canvas.drawRRect(
          RRect.fromLTRBR(
            image2OffsetX + shadowOffsetX,
            image2OffsetY + shadowOffsetY,
            image2OffsetX + imageWidth + shadowOffsetX,
            image2OffsetY + imageHeight + shadowOffsetY,
            Radius.circular(imageBorderRadius),
          ),
          Paint()
            ..color = Colors.black.withAlpha(shadowAlpha)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal,
                ImageUtils.convertRadiusToSigma(shadowRadius)));

      // Draw Image
      canvas.drawImage(
        resizedImage,
        Offset(image2OffsetX, image2OffsetY),
        Paint(),
      );
    }
    if (image1 != null) {
      final resizedImage = await ImageUtils.clipImageToRRect(
        image1,
        imageWidth,
        imageHeight,
        imageBorderRadius,
      );

      canvas.drawRRect(
          RRect.fromLTRBR(
            shadowOffsetX,
            shadowOffsetY,
            imageWidth + shadowOffsetX,
            imageHeight + shadowOffsetY,
            Radius.circular(imageBorderRadius),
          ),
          Paint()
            ..color = Colors.black.withAlpha(shadowAlpha)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal,
                ImageUtils.convertRadiusToSigma(shadowRadius)));

      // Draw image
      canvas.drawImage(
        resizedImage,
        Offset(0, 0),
        Paint(),
      );
    }

    final image = await pictureRecorder.endRecording().toImage(
          fullCanvasWidthEstimate.toInt(),
          fullCanvasHeightEstimate.toInt(),
        );

    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(userPlacardsModel.id),
      position: LatLng(userPlacardsModel.latitude, userPlacardsModel.longitude),
      icon: _image,
      onTap: _tapCallback,
    );
  }
}
