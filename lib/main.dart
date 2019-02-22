import 'package:flutter/material.dart';
import 'package:hearai/splash.dart';
import 'package:hearai/home.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async { 
  cameras = await availableCameras();
  runApp(HearAI());
}

class HearAI extends StatefulWidget {
  @override
  _HearAIState createState() => _HearAIState();
}

class _HearAIState extends State<HearAI> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(cameras),//cameras),
      routes: {
        '/home': (context) => Home(cameras),
        '/splash': (context) => Splash(cameras),
        '/setup': (context) => Setup(),
      },
    );
  }


}
