// chip 8 screen is 64x32

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var _scaleFactor = 6.0;
var _stroke = _scaleFactor + 0.2;

class Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: 64 * _scaleFactor,
      height: 32 * _scaleFactor,
      child: CustomPaint(painter: ScreenPainter()),
    );
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = Colors.white;

    canvas.drawRawPoints(PointMode.points, diagonalLine(), p);
  }

  diagonalLine() {
    // y = m x
    int totalPoints = (((32*_scaleFactor)*(64*_scaleFactor))*2).toInt();
    var res = List<double>();
    int k = 0;
    // print all screen
    // diagonal from 0,0 to 64,32
    var m = 32/64;
    for (double i = 0; i < 32.0; i++) {
      for (double j = 0; j < 64.0; j++) {
        // y = mx
        var yTest = i;
        var xTest = j;
        bool paint = yTest == xTest * m;
        if (paint) {
          res.add((xTest * _scaleFactor) + (_stroke*0.5));
          res.add((yTest * _scaleFactor) + (_stroke*0.5));
          ++k;
        }

      }
    }
    return Float32List.fromList(res);
  }

  allScreenPoints() {
    int totalPoints = (((32*_scaleFactor)*(64*_scaleFactor))*2).toInt();
    var res = Float32List(totalPoints);
    int k = 0;
    // print all screen
    for (double i = 0; i < 32.0; i++) {
      for (double j = 0; j < 64.0; j++) {
        // add as many points as scaled
        res[k]= (j * _scaleFactor) + (_scaleFactor*0.5);
        res[++k]= (i * _scaleFactor) + (_scaleFactor*0.5);
        ++k;

      }
    }
    return res;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    //throw UnimplementedError();
    return true;
  }
}