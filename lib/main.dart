import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chip_8/controller.dart';
import 'package:flutter_chip_8/machine.dart';
import 'package:flutter_chip_8/rom_loader.dart';

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
      debugShowCheckedModeBanner: false,
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

  Isolate _isolate;
  bool started = false;

  final ScreenData screenData = ScreenData();
  final KeyData keyData = KeyData();


  @override
  void initState() {
    keyData.addListener(_onKeyPressed);
  }

  _MyHomePageState();

  void _onKeyPressed() {
    // do something with the pressed key
    if (keyData.key != null)
      print('key was pressed');
    else
      print('key was released');
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
    final Machine machine = Machine();
    machine.run(rom, isolateToMainStream, mainToIsolateStream);

  }

  void _handleMessage(dynamic data) {
    switch (data[0]) {
      case Operations.Communication:
        _machineSender = data[1];
        break;
      case Operations.Stopped:
        _receivePort.close();
        _isolate.kill(priority: Isolate.immediate);
        _isolate = null;
        started = false;
        break;
      case Operations.Running:
        break;
      case Operations.UpdateScreen:
        screenData.update(data[1]);
        // _key.currentState.updateImage(data[1]);
        break;
    }
  }

  void _stopSim() {
    if (started) {
      _machineSender.send([Operations.Stop]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Column(children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // chip 8 data is 32x64 screen so adjust to available space
                    // and also make it a power of 2
                    double w = (constraints.maxWidth.toInt() -
                            (2 - (constraints.maxWidth.toInt() % 2)) % 2)
                        .toDouble();
                    double h =
                        (ScreenData.designHeight * w) / ScreenData.designWidth;
                    h = (h.toInt() - (2 - (h.toInt() % 2)) % 2).toDouble();
                    return Screen(this.screenData, width: w, height: h);
                  },
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    var l = constraints.maxWidth * 0.75;

                    return Container(
                      child: Controller(keyData),
                      width: l,
                      height: l,
                    );
                  }),
                )
              ]))),
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
      ),
    );
  }


}
