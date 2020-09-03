// chip 8 screen is 64x32

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'bitmap.dart';

var _scaleFactor = 6.0;

class Screen extends StatefulWidget {
  Screen({Key key}) : super(key: key) {}

  @override
  State<Screen> createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  Image image;

  updateImage(img) {
    setState(() {
      image = img;
    });
  }

  @override
  void initState() {
    super.initState();
    image = genImage();
  }

  Image genImage() {
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

  @override
  Widget build(BuildContext context) {
    var r = Container(
      color: Colors.black,
      width: 64 * _scaleFactor,
      height: 32 * _scaleFactor,
      child: image,
    );
    return r;
  }
}
