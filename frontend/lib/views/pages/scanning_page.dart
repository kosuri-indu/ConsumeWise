import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';

class ScanningPage extends StatefulWidget {
  @override
  _ScanningPageState createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  String _scannedText = "Scan food label to extract details";
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() => _isCameraInitialized = true);
      } else {
        setState(() => _scannedText = "No cameras available.");
      }
    } catch (e) {
      setState(() => _scannedText = "Camera error: ${e.toString()}");
    }
  }

  Future<void> _scanFoodLabel() async {
    if (!_isCameraInitialized || _isScanning) return;

    setState(() => _isScanning = true);

    try {
      XFile picture = await _cameraController!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(imagePath: picture.path),
        ),
      );
    } catch (e) {
      setState(() => _scannedText = "Error: ${e.toString()}");
    }

    setState(() => _isScanning = false);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isCameraInitialized
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _animation.value * 280),
                        child: Container(
                          width: 300,
                          height: 4,
                          color: Colors.greenAccent,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: FloatingActionButton(
              onPressed: _scanFoodLabel,
              backgroundColor: Colors.green,
              child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultPage extends StatelessWidget {
  final String imagePath;

  ScanResultPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            SizedBox(height: 20),
            Text("Scanned Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
