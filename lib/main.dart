import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  AudioPlayer _player;
  File _writtenFile;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void setPlayer() async {
    //Write bundled file to local app folder
    if (_writtenFile == null) {
      log('- Write to File');
      ByteData bytes = await rootBundle.load('assets/test.m4a'); //test file

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      File file = File('$appDocPath/testing.m4a');
      _writtenFile = await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      log('- File path: ${_writtenFile.path}');
    }

    //Set the file path of player
    final d = await _player.setFilePath(_writtenFile.path);
    log('- setPlayer() Duration: $d');

    if (d != null) {
      _player.play();
    }
  }

  void log(String line) {
    setState(() {
      print(_log);
      final now = DateTime.now();
      final formattedDate = DateFormat('hh:mm:ss').format(now);
      _log = '$formattedDate: $line\n$_log';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Set the player'),
              onPressed: setPlayer,
            ),
            Text('$_log'),
          ],
        ),
      ),
    );
  }
}
