import 'package:flutter/material.dart';
import 'package:hearai/cameraScreen.dart';
import 'package:camera/camera.dart';

class Home extends StatefulWidget {
  var cameras;
  Home(this.cameras);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new CameraScreen(widget.cameras),//widget.cameras),
      );
  }

}