import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:hearai/home.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String _platformVersion = 'Uknown';

  //Shared preferences screen
  Future checkSeen() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool _seen = (preferences.getBool("seen") ?? false);
    print("seen within check func " + _seen.toString());
    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Home()));
    } else {
      preferences.setBool("seen", true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Setup()));
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    new Timer(new Duration(microseconds: 200), () {
      checkSeen();
    });
  }

  initPlatformState() async {
    String platformVersion;

    try {
      platformVersion = await SimplePermissions.platformVersion;
    } catch (PlatformException) {
      platformVersion = "Failed to get platform version";
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class Setup extends StatefulWidget {
  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Permission permission = Permission.RecordAudio;
  var dialogNum = 0;

  Future _speak() async {
    print("HERE IS THE VALUE OF IT: $dialogNum");
    var msg = [
      "Hello an welcome to Hear AI. This is our one time setup Screen. I am your assistant. I am Here to guide you through! Lets get Started",
      "What is your Name?",
      "Select reading speed. Slow, Fast or Normal. This text is read at Normal speed."
    ];
    await FlutterTts().speak(msg[dialogNum]);
    await FlutterTts().setSpeechRate(1.0);

    setState(() {
      dialogNum++;
    });
  }

  Future _stop() async {
    await FlutterTts().stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Center(
              child: Text(
                "Welcome To Hear AI Setup!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Center(
              child: RaisedButton(
                child: Text("Home"),
                onPressed: (){Navigator.pushReplacementNamed(context, "/home");},
              )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          requestPermission(permission);
          _speak();
        },
        child: Icon(Icons.mic),
        elevation: 6.0,
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Future requestPermission(Permission permission) async {
  final res = await SimplePermissions.requestPermission(permission);
  print("Permission is " + res.toString());
}

Future permissionStatus(Permission permission) async {
  final res = await SimplePermissions.getPermissionStatus(permission);
}
