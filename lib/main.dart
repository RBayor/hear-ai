import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:hearai/detector_painters.dart';
import 'package:hearai/utils.dart';
import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  cameras = await availableCameras();
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
  dynamic _scanResults;
  CameraController _cameraController;
  bool isImageLoaded = false;

  Detector _currentDetector = Detector.text;
  bool _isDetecting = false;
  int _direction = 0;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    preInitCam();
  }

  Future preInitCam() async {
    _cameraController =
        new CameraController(cameras[_direction], ResolutionPreset.medium);
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      _initializeCamera();
      setState(() {});
    });
  }

  Future _initializeCamera() async {
    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      print("STARTING IMAGE STREAM");
      _isDetecting = true;

      detect(image, _getDetecttionMethod()).then((dynamic result) {
        setState(() {
          _scanResults = result;
        });
        _isDetecting = false;
      }).catchError(
        (_) {
          _isDetecting = false;
        },
      );
    });
  }

  HandleDetection _getDetecttionMethod() {
    final FirebaseVision mlVision = FirebaseVision.instance;

    print("We are trying to detect $_currentDetector");

    switch (_currentDetector) {
      case Detector.text:
        return (mlVision.textRecognizer().processImage);
      case Detector.barcode:
        return mlVision.barcodeDetector().detectInImage;
      case Detector.label:
        return mlVision.labelDetector().detectInImage;
      case Detector.cloudLabel:
        return mlVision.cloudLabelDetector().detectInImage;
      default:
        assert(_currentDetector == Detector.face);
        return mlVision.faceDetector().processImage;
    }
  }

  Widget _buildResults() {
    const Text noResultsText = const Text("Nothing found");
    print("IN BUIlD RESULT METHOD");
    if (_scanResults == null ||
        _cameraController == null ||
        !_cameraController.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(_cameraController.value.previewSize.height,
        _cameraController.value.previewSize.width);

    switch (_currentDetector) {
      case Detector.barcode:
        if (_scanResults is! List<Barcode>) return Text("is not barcode");
        painter = BarcodeDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.face:
        if (_scanResults is! List<Face>) return Text("is not face");
        painter = FaceDetectorPainter(imageSize, _scanResults);
        break;
      case Detector.label:
        if (_scanResults is! List<Label>) return noResultsText;
        painter = LabelDetectorPainter(imageSize, _scanResults);
        break;
      default:
        assert(_currentDetector == Detector.text);
        if (_scanResults is! VisionText) return noResultsText;
        painter = TextDetectorPainter(imageSize, _scanResults);
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    print("IN BUIlD IMAGE METHOD");
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _cameraController == null
          ? const Center(child: Text("hmmm...."))
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_cameraController),
                _buildResults(),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImage(),
      floatingActionButton: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.redAccent,
            elevation: 6.0,
            onPressed: () {},
            child: Icon(Icons.textsms),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
          ),
        ),
      ),
    );
  }
}
