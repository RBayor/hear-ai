import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:hearai/detector_painters.dart';
import 'package:hearai/utils.dart';
import 'dart:async';

class CameraScreen extends StatefulWidget {
  List<CameraDescription> cameras;

  CameraScreen(this.cameras);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  dynamic _scanResults;
  CameraController _cameraController;

  Detector _currentDetector = Detector.text;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _cameraController =
        new CameraController(widget.cameras[0], ResolutionPreset.medium);
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      _initializeCamera();
      setState(() {});
    });
    //_initializeCamera();
  }

  Future _initializeCamera() async {
    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      print("STARTING IMAGE STREAM");
      _isDetecting = true;
      detect(image, _getDetecttionMethod()).then((dynamic result) {
        setState(() {
          _scanResults = result;
          print("this is the scan " + _scanResults.toString());
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

    //_currentDetector =Detector.text;
    print("You are detecting $_currentDetector");

    switch (_currentDetector) {
      case Detector.text:
        return mlVision.textRecognizer().processImage;
      case Detector.barcode:
        return mlVision.barcodeDetector().detectInImage;
      case Detector.label:
        return mlVision.labelDetector().detectInImage;
      default:
        assert(_currentDetector == Detector.face);
        return mlVision.faceDetector().processImage;
    }
  }

  Widget _buildResults() {
    const Text noResultsText = const Text("Nothing found");
    print("IN BuilD RESULT METHOD");
    print("Scan result is $_currentDetector");
    if (_scanResults == null ||
        _cameraController == null ||
        !_cameraController.value.isInitialized) {
          print("We are getting null values in buid result");
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(_cameraController.value.previewSize.height,
        _cameraController.value.previewSize.width);

    switch (_currentDetector) {
      case Detector.barcode:
        if (_scanResults is! List<Barcode>) return Text("Scan not a barcode");
        painter = BarcodeDetectorPainter(imageSize, _scanResults);
        print("Its a bar code");
        break;
      case Detector.text:
        if (_scanResults is! VisionText) return Text("Scan is not vision Text");
        painter = TextDetectorPainter(imageSize, _scanResults);
        print("Its text!!!!");
        break;
      case Detector.label:
        if (_scanResults is! List<Label>) return Text("Scan label");
        painter = LabelDetectorPainter(imageSize, _scanResults);
        print("Its an image");
        break;
      default:
        assert(_currentDetector == Detector.face);
        if (_scanResults is! VisionText) return Text("Scan not face");
        painter = FaceDetectorPainter(imageSize, _scanResults);
        print("Its a face");
    }

    return CustomPaint(
      painter: painter,
    );
  }

  /*_lead() {
    Timer(Duration(seconds: 5), () {
      _buildResults();
    });
  }*/

  Widget _buildImage() {
    print("IN BuilD IMAGE METHOD");
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

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _cameraController.stopImageStream();
    await _cameraController.dispose();

    setState(() {
      _cameraController = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Barcode'),
                    value: Detector.barcode,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Face'),
                    value: Detector.face,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Label'),
                    value: Detector.label,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Text'),
                    value: Detector.text,
                  ),
                ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _initializeCamera();
        }, //_toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }
/**
 * Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Barcode'),
                    value: Detector.barcode,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Face'),
                    value: Detector.face,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Label'),
                    value: Detector.label,
                  ),
                  const PopupMenuItem<Detector>(
                    child: Text('Detect Text'),
                    value: Detector.text,
                  ),
                ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
 */
}
