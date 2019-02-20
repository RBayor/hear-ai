import 'package:flutter/material.dart';
import 'package:hearai/splash.dart';
import 'package:hearai/home.dart';

void main() => runApp(HearAI());

class HearAI extends StatefulWidget {
  @override
  _HearAIState createState() => _HearAIState();
}

class _HearAIState extends State<HearAI> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splash(),
      routes: {
        '/home': (context) => Home(),
        '/splash': (context) => Splash(),
        '/setup': (context) => Setup(),
      },
    );
  }


}
