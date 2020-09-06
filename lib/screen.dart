// chip 8 screen is 64x32

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'bitmap.dart';

class ScreenData extends ChangeNotifier {
  Image image;
  BuildContext context;

  ScreenData() {
    this.image = _genImage();
  }

  Image _genImage() {
    //use this.screen to gen the picture
    var imageData = Uint8List(32 * 64 * 3);
    for (int i = 0; i < 32 * 64 * 3; i += 3) {
      imageData[i] = 0; //blue
      imageData[i + 1] = 0; //green
      imageData[i + 2] = 255; //red
    }
    var data = createBitmap(64, 32, imageData);
    return Image.memory(data, width: 64, height: 30, fit: BoxFit.cover);
  }

  update(final Image img) async {
    await precacheImage(img.image, context);
    this.image = img;
    notifyListeners();
  }
}


class Screen extends StatefulWidget {
  final ScreenData data;
  final double height;
  final double width;

  Screen(this.data, {this.height, this.width});

  @override
  State<Screen> createState() => ScreenState();
}

class ScreenState extends State<Screen> {


  Image img;
  int fpsCount = 0;
  Stopwatch watch;

  void _onDataChange() {
    setState(() {
      img = this.widget.data.image;
    });
  }

  @override
  void initState() {
    super.initState();
    this.img = this.widget.data.image;
    this.widget.data.context = this.context;
    this.widget.data.addListener(_onDataChange);
    watch = Stopwatch();
    watch.start();
  }


  @override
  Widget build(BuildContext context) {
    fpsCount++;
    if (watch.elapsedMilliseconds >= 1000) {
      print("FPS=" + fpsCount.toString());
      fpsCount = 0;
      watch.reset();
    }

    // this is a portrait app, use all the width and calculte height
    // context.size.width
    return Container(child: img, width: this.widget.width, height: this.widget.height);
  }
}
