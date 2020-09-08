import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// the key pad controller for chip8
class Controller extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ControllerState();
}

class ControllerState extends State<Controller> {
  /*
   * chip 8 keyboard layout
   *    1 2 3 C
   *    4 5 6 D
   *    7 8 9 E
   *    A 0 B F
   */
  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(3);
    return GridView.count(


      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 4,
      children: <Widget>[
        //  1 2 3 C
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: Text('1'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('2'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('3'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('C'),
        ),
        // 4 5 6 D
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text("4"),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('5'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('6'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('D'),
        ),
        // 7 8 9 E
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text("7"),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('8'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('9'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('E'),
        ),
        // A 0 B F
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text("A"),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('0'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('B'),
        ),
        RaisedButton(
          onPressed: () {},
          padding: padding,
          child: const Text('F'),
        ),
      ],
    );
  }
}
