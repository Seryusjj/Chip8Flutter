// chip 8 screen is 64x32

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dart:ui' as ui;

class ScreenData extends ChangeNotifier {
  ui.Image image;
  final int designWidth = 64;
  final int designHeight = 32;

  int targetWidth;
  int targetHeight;

  ScreenData() {
    // _preInit();
  }

  _preInit() async {
    await update(_genDefaultImageUI());
  }

  Uint8List _genDefaultImageUI() {
    //use this.screen to gen the picture
    var imageData = Uint8List(designHeight * designWidth * 4);
    for (int i = 0; i < 32 * 64 * 4; i += 4) {
      imageData[i] = 0; //r
      imageData[i + 1] = 0; //g
      imageData[i + 2] = 0; //b
      imageData[i + 3] = 255; //a
    }

    return imageData;
  }

  update(final Uint8List rgba) async {
    // await imgCompleter.complete(img.image);
    //await precacheImage(img.image, context);
    this.image = await _createUIImg(rgba);
    notifyListeners();
  }

  Future<ui.Image> _createUIImg(final Uint8List rgba) async {
    // var res = createBitmap(w, h, rgb);
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
    data.targetWidth = width.toInt() - (2 - (width.toInt() % 2)) % 2;
    data.targetHeight = height.toInt() - (2 - (height.toInt() % 2)) % 2;
    return Container(
      child: CustomPaint(painter: ImagePainter(data)),
      width: data.targetWidth.toDouble(),
      height: data.targetHeight.toDouble(),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ScreenData data;
  final Offset offset = Offset(0, 0);
  final Paint p = Paint();
  int _frames = 0;
  Stopwatch _watch = Stopwatch();

  ImagePainter(this.data) : super(repaint: data) {
    data._preInit();
    _watch.start();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Size imageSize =
        Size(data.designWidth.toDouble(), data.designHeight.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.cover, imageSize, size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, Offset.zero & size);

    if (data.image != null) {
      canvas.drawImageRect(data.image, inputSubrect, outputSubrect, p);
      _frames++;
      if (_watch.elapsedMilliseconds >= 1000) {
        print("FPS=" + _frames.toString());
        _watch.reset();
        _frames = 0;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
