import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chip_8/machine.dart';
import 'package:flutter_chip_8/rom_loader.dart';

import 'bitmap.dart';
import 'screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chip 8',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Chip 8'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static List<String> debugInfo = List<String>();
  SendPort _machineSender;
  ReceivePort _receivePort;
  String text = '';
  Isolate _isolate;
  bool started = false;

  Image screenImage;

  _MyHomePageState() {
    screenImage = genImage();
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

  void _startSim() async {
    if (!started) {
      _receivePort = ReceivePort();
      debugInfo.clear();
      var rom = await RomLoader().loadAsset();
      _isolate =
          await Isolate.spawn(_startEmulation, [_receivePort.sendPort, rom]);
      _receivePort.listen(_handleMessage);
      started = true;
    }
  }

  static void _startEmulation(dynamic data) async {
    SendPort isolateToMainStream = data[0];
    var rom = data[1];
    ReceivePort mainToIsolateStream = ReceivePort();
    isolateToMainStream
        .send([Operations.Communication, mainToIsolateStream.sendPort]);
    var machine = Machine();
    machine.run(rom, isolateToMainStream, mainToIsolateStream);
  }

  var c = 0;
  void _handleMessage(dynamic data) {
    switch(data[0]) {
      case Operations.Communication:
        _machineSender = data[1];
        break;
      case Operations.Stopped:
        _showState();
        _receivePort.close();
        _isolate.kill(priority: Isolate.immediate);
        _isolate = null;
        started = false;
        break;
      case Operations.Running:
        break;
      case Operations.UpdateScreen:
        _key.currentState.updateImage(data[1]);
        print("Update screen" + c.toString());
        c++;
        break;
    }
  }



  _showState() {
    setState(() {
      text = "";
      for (var i = 0; i < debugInfo.length; i++) {
        text += debugInfo[i] + "\n";
      }
    });
  }

  void _stopSim() {
    if (started) {
      _machineSender.send([Operations.Stop]);
    }
  }
  final _key = GlobalKey<ScreenState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Screen(key: _key),
            alignment: Alignment.topCenter,
            margin: EdgeInsets.fromLTRB(0, 60, 0, 0)),
        floatingActionButton: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(2.0),
              child: FloatingActionButton(
                  onPressed: _startSim,
                  tooltip: 'Start',
                  backgroundColor: Colors.green,
                  child: Icon(Icons.play_arrow)),
            ),
            Padding(
                padding: EdgeInsets.all(2.0),
                child: FloatingActionButton(
                    onPressed: _stopSim,
                    backgroundColor: Colors.red,
                    tooltip: 'Stop',
                    child: Icon(Icons.stop))),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
