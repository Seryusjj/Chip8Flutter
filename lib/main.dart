import 'package:flutter/material.dart';
import 'package:flutter_chip_8/machine.dart';
import 'package:flutter_chip_8/rom_loader.dart';

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
  List<String> debugInfo = List<String>();
  String text = '';

  void _incrementCounter() {
    RomLoader loader = RomLoader();
    Machine machine = Machine();

    loader.loadTestRom((val) => machine.process(
          val,
          debugInfo,
          () => setState(() {
            text = "";
            for (var i = 0; i < debugInfo.length; i++) {
              text = text + debugInfo[i] + "\n";
            }
          }),
        ));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

        child: SingleChildScrollView(child: Text(text))
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
