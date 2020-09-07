// chip 8 screen is 64x32

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:ui' as ui;

class ScreenData extends ChangeNotifier {
  ui.Image image;
  static const designWidth = 64;
  static const designHeight = 32;

  _preInit() async {
    await update(_genDefaultImageUI());
  }

  Uint8List _genDefaultImageUI() {
    const dataLength = designHeight * designWidth * 4;

    var imageData = Uint8List(dataLength);
    for (int i = 0; i < dataLength; i += 4) {
      imageData[i] = 0; //r
      imageData[i + 1] = 0; //g
      imageData[i + 2] = 0; //b
      imageData[i + 3] = 255; //a
    }

    return imageData;
  }

  update(final Uint8List rgba) async {
    this.image = await _createUIImg(rgba);
    notifyListeners();
  }

  Future<ui.Image> _createUIImg(final Uint8List rgba) async {
    var completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(rgba, designWidth, designHeight,
        ui.PixelFormat.rgba8888, (img) => completer.complete(img));
    return completer.future;
  }
}

class Screen extends StatelessWidget {
  final ScreenData data;
  final double height;
  final double width;

  Screen(this.data, {this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(painter: ImagePainter(data)),
      width: width,
      height: height,
    );
  }
}

class ImagePainter extends CustomPainter {
  final ScreenData data;
  final Offset offset = Offset(0, 0);
  final Paint p = Paint();
  int _frames = 0;
  final Stopwatch _watch = Stopwatch();

  ImagePainter(this.data) : super(repaint: data) {
    data._preInit();
    _watch.start();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Size imageSize = Size(
      ScreenData.designWidth.toDouble(),
      ScreenData.designHeight.toDouble(),
    );
    final FittedSizes sizes = applyBoxFit(
      BoxFit.cover,
      imageSize,
      size,
    );
    final Rect inputSubRect = Alignment.center.inscribe(
      sizes.source,
      Offset.zero & imageSize,
    );
    final Rect outputSubRect = Alignment.center.inscribe(
      sizes.destination,
      Offset.zero & size,
    );

    if (data.image != null) {
      canvas.drawImageRect(data.image, inputSubRect, outputSubRect, p);

      // dirty hack to have this code only on debug
      assert(() {
        _frames++;
        if (_watch.elapsedMilliseconds >= 1000) {
          // print("FPS=" + _frames.toString());
          _watch.reset();
          _frames = 0;
        }
        return true;
      }());

    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
