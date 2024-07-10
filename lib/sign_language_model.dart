import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite/tflite.dart';
// ignore: unused_import
import 'package:flutter_logs/flutter_logs.dart';

class SignLanguageModel extends StatefulWidget {
  const SignLanguageModel({Key? key});

  @override
  _SignLanguageModelState createState() => _SignLanguageModelState();
}

class _SignLanguageModelState extends State<SignLanguageModel> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  final List<String> _actions = [
    'Hi',
    'Terima Kasih',
    'Bantu',
    'Nama',
    'Ya',
    'Tidak',
    'Minta',
    'Saya',
    'Awak',
    'Maaf',
    'Apa',
    'Sama-sama',
    'A',
    'B',
    'C'
  ];
  String _recognizedAction = ''; // Variable to store the recognized action
  get log => log('SignLanguageModel'); // Define a logger instance

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      _cameras = await availableCameras();
      _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
      await _cameraController.initialize();
    } catch (e) {
      log.info('Error initializing camera: $e');
      // Handle initialization error (e.g., show error message, retry logic)
    }
  }

  void _loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
    );
    log.info("Model loaded: $res");
  }

  Future<Uint8List> _processCameraImage(CameraImage image) async {
    if (!_isDetecting) {
      _isDetecting = true;

      // Convert CameraImage to a normalized image (e.g., resize)
      final img.Image? normalizedImage = img.decodeImage(image.planes[0].bytes);
      if (normalizedImage == null) {
        log.warning("Failed to normalize image");
        _isDetecting = false;
        return Uint8List(0);
      }
      final img.Image resizedImage = img.copyResize(normalizedImage,
          width: 224, height: 224); // Assuming model expects 224x224

      // Convert the resized image to a Uint8List for TfLite
      final Uint8List convertedBytes = resizedImage.getBytes();

      // Run inference on the model
      var output = await Tflite.runModelOnBinary(
        binary: convertedBytes,
      );

      log.info("Model output: $output");

      // Check if the output is a list or tensor
      if (output is List && output.isNotEmpty) {
        // Assuming output is a list of probabilities
        final List<double> probabilities = output[0].cast<double>();

        // Find the index of the predicted sign (highest probability)
        final int predictedIndex = probabilities.indexOf(probabilities.reduce(max));

        // Get the confidence score for the predicted sign
        final double confidenceScore = probabilities[predictedIndex];

        // Update the recognized action variable and log the confidence score
        setState(() {
          _recognizedAction = _actions[predictedIndex];
          log.info("Predicted action: $_recognizedAction, Confidence: $confidenceScore");
        });
      } else {
        // Handle unexpected output format (log an error or warning)
        log.warning("Unexpected output format from model");
      }
      _isDetecting = false;
    }
    return Uint8List(0); // Placeholder for future use
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('SignBridge'),
            ),
            body: Stack(
              children: <Widget>[
                // Background image container
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background.jpeg'), // Adjust asset path as necessary
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Centered white container with rounded corners and padding
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                            child: CameraPreview(_cameraController),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              _recognizedAction.isEmpty ? 'Recognizing...' : _recognizedAction,
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Ensure text color is black
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error initializing camera: ${snapshot.error}'),
          );
        }
        return Center(child: CircularProgressIndicator()); // Show loading indicator or placeholder
      },
    );
  }
}
