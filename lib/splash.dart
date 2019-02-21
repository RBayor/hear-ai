import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:hearai/home.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_recognition/speech_recognition.dart';

class Splash extends StatefulWidget {
  var cameras;
  Splash(this.cameras);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String _platformVersion = 'Uknown';
  var cameras;

  //Shared preferences screen
  Future checkSeen() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool _seen = (preferences.getBool("seen") ?? false);
    print("seen within check func " + _seen.toString());
    if (_seen) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new Home(cameras)));
    } else {
      preferences.setBool("seen", false);
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

  void initPlatformState() async {
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
  SpeechRecognition _speech = new SpeechRecognition();
  bool _speechRecognitionAvailable;
  String _currentLocale;
  bool _isListening = false;
  String _readSpeed = "normal";

  Future _speak() async {
    print("HERE IS THE VALUE OF IT: $dialogNum");

    if (dialogNum == 3) {
      await FlutterTts().speak(
          "Speed set to $_readSpeed. Continue to home. You can come back, and change this at anytime");
    }

    if (dialogNum == 2) {
      await speechRecognition();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        preferences.setString("readSpeed", _readSpeed);
        print("Read speed set to $_readSpeed");
      });
    }

    var msg = [
      "Hello and welcome to Hear AI. This is our one time setup Screen. I am your assistant. I am Here to guide you through! Lets get Started",
      "Would you like a slow, fast, or, you will stick with normal reading speed.",
      ""
    ];
    await FlutterTts().speak(msg[dialogNum]);
    await FlutterTts().setSpeechRate(1.0);

    setState(() {
      if (dialogNum > 3) return;
      dialogNum++;
    });
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));

    _speech.setAvailabilityHandler(
        (bool result) => setState(() => _speechRecognitionAvailable = result));

    _speech.setCurrentLocaleHandler(
        (String locale) => setState(() => _currentLocale = locale));
  }

  Future speechRecognition() async {
    _speech
        .listen(locale: _currentLocale)
        .then((result) => print('result : $result'));

    _speech.setRecognitionStartedHandler(
        () => setState(() => _isListening = true));

    _speech.setRecognitionResultHandler(
        (String text) => setState(() => _readSpeed = text));

    _speech.setRecognitionCompleteHandler(
        () => setState(() => _isListening = false));

    if (!mounted) {
      _speech.stop();
    }
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
          Text("Read Speed: $_readSpeed"),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Center(
                child: RaisedButton(
              child: Text("Home"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
            )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          requestPermission(permission);
          _speak();
          //_speak();
          //speechRecName();
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
