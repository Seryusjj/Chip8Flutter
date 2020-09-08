import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeyData extends ChangeNotifier {
  int key = null;

  void _keyDown1(PointerDownEvent event) {
    key = 1;
    notifyListeners();
  }

  void _keyUp1(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown2(PointerDownEvent event) {
    key = 2;
    notifyListeners();
  }

  void _keyUp2(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown3(PointerDownEvent event) {
    key = 3;
    notifyListeners();
  }

  void _keyUp3(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownC(PointerDownEvent event) {
    key = 0xC;
    notifyListeners();
  }

  void _keyUpC(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown4(PointerDownEvent event) {
    key = 4;
    notifyListeners();
  }

  void _keyUp4(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown5(PointerDownEvent event) {
    key = 5;
    notifyListeners();
  }

  void _keyUp5(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown6(PointerDownEvent event) {
    key = 6;
    notifyListeners();
  }

  void _keyUp6(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownD(PointerDownEvent event) {
    key = 0xD;
    notifyListeners();
  }

  void _keyUpD(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown7(PointerDownEvent event) {
    key = 7;
    notifyListeners();
  }

  void _keyUp7(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown8(PointerDownEvent event) {
    key = 8;
    notifyListeners();
  }

  void _keyUp8(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown9(PointerDownEvent event) {
    key = 9;
    notifyListeners();
  }

  void _keyUp9(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownE(PointerDownEvent event) {
    key = 0xE;
    notifyListeners();
  }

  void _keyUpE(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownA(PointerDownEvent event) {
    key = 0xA;
    notifyListeners();
  }

  void _keyUpA(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDown0(PointerDownEvent event) {
    key = 0;
    notifyListeners();
  }

  void _keyUp0(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownB(PointerDownEvent event) {
    key = 0xB;
    notifyListeners();
  }

  void _keyUpB(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }

  void _keyDownF(PointerDownEvent event) {
    key = 0xF;
    notifyListeners();
  }

  void _keyUpF(PointerUpEvent event) {
    key = null;
    notifyListeners();
  }
}

/*
   * chip 8 keyboard layout
   *    1 2 3 C
   *    4 5 6 D
   *    7 8 9 E
   *    A 0 B F
   */
class Controller extends StatelessWidget {
  final KeyData keyData;

  Controller(this.keyData);

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(0);
    const textStyle = TextStyle(fontSize: 20);
    return GridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 4,
      children: <Widget>[
        //  1 2 3 C
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown1,
          onPointerUp: keyData._keyUp1,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('1', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown2,
          onPointerUp: keyData._keyUp2,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('2', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown3,
          onPointerUp: keyData._keyUp3,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('3', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownC,
          onPointerUp: keyData._keyUpC,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('C', style: textStyle),
        ),
        // 4 5 6 D
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown4,
          onPointerUp: keyData._keyUp4,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('4', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown5,
          onPointerUp: keyData._keyUp5,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('5', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown6,
          onPointerUp: keyData._keyUp6,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('6', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownD,
          onPointerUp: keyData._keyUpD,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('D', style: textStyle),
        ),
        // 7 8 9 E
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown7,
          onPointerUp: keyData._keyUp7,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('7', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown8,
          onPointerUp: keyData._keyUp8,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('8', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown9,
          onPointerUp: keyData._keyUp9,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('9', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownE,
          onPointerUp: keyData._keyUpE,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('E', style: textStyle),
        ),
        // A 0 B F
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownA,
          onPointerUp: keyData._keyUpA,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('A', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDown0,
          onPointerUp: keyData._keyUp0,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('0', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownB,
          onPointerUp: keyData._keyUpB,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('B', style: textStyle),
        ),
        ListenerButton(
          padding: padding,
          onPointerDown: keyData._keyDownF,
          onPointerUp: keyData._keyUpF,
          notPressedColor: Colors.black12,
          pressedColor: Colors.black38,
          child: Text('F', style: textStyle),
        ),
      ],
    );
  }
}

class ListenerButton extends StatefulWidget {
  Widget child;
  EdgeInsets padding;
  PointerDownEventListener onPointerDown;
  PointerUpEventListener onPointerUp;
  Color pressedColor;
  Color notPressedColor;

  ListenerButton(
      {this.child,
      this.padding,
      this.onPointerDown,
      this.onPointerUp,
      this.pressedColor,
      this.notPressedColor});

  @override
  State<StatefulWidget> createState() => ListenerButtonState();
}

class ListenerButtonState extends State<ListenerButton> {
  Color currentColor;

  _pointerDown(PointerDownEvent event) {
    if (widget.onPointerDown != null) {
      widget.onPointerDown(event);
    }
    setState(() {
      currentColor = widget.pressedColor;
    });
  }

  _pointerUp(PointerUpEvent event) {
    if (widget.onPointerUp != null) {
      widget.onPointerUp(event);
    }
    setState(() {
      currentColor = widget.notPressedColor;
    });
  }

  @override
  void initState() {
    this.currentColor = widget.notPressedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Listener(
          onPointerDown: _pointerDown,
          onPointerUp: _pointerUp,
          child: Container(
              color: currentColor, child: Center(child: widget.child))),
    );
  }
}
