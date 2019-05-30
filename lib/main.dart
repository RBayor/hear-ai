import 'dart:convert';
import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

Future<void> main() async {
  runApp(HearAI());
}

class HearAI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ML(),
    );
  }
}

class ML extends StatefulWidget {
  @override
  _MLState createState() => _MLState();
}

class _MLState extends State<ML> {
  File pickedImage;
  bool isImage = false;
  var flutterTts = new FlutterTts();

  Future pickImage() async {
    flutterTts.stop();
    var tempImg = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = tempImg;
      isImage = true;
    });

    if (isImage == true) {
      readText();
    }
  }

  Future readText() async {
    flutterTts.stop();
    var _mytext = [];
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          //print(element.text);
          //await _speak(block.text);
        }
        _mytext.add(line.text);
      }
    }

    print(_mytext);
    _speak(_mytext);
  }

  Future _speak(List line) async {
    await flutterTts.speak(line.toString());
  }

  @override
  void initState() {
    super.initState();
    pickImage();
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isImage
            ? Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(pickedImage), fit: BoxFit.contain),
                  ),
                ),
              )
            : Container(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.camera,
                color: Colors.white,
              ),
              onPressed: pickImage,
            ),
            FloatingActionButton(
              backgroundColor: Colors.purple,
              child: Icon(
                Icons.speaker,
                color: Colors.white,
              ),
              onPressed: readText,
            ),
          ],
        ));
  }
}
