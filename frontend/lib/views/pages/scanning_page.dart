import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'analysis_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/colors.dart'; // Import your colors file

class ScanningPage extends StatefulWidget {
  final Map<String, dynamic> userProfile; // Add userProfile parameter

  ScanningPage({required this.userProfile}); // Constructor with userProfile

  @override
  _ScanningPageState createState() => _ScanningPageState();
}

class _ScanningPageState extends State<ScanningPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isScanning = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchUserProfile();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userProfile = userProfileSnapshot.data();
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController =
        CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController?.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    setState(() => _isScanning = true);

    final imageFile = await _cameraController!.takePicture();

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile != null) {
      final text = await _processText(croppedFile.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisPage(
            scannedText: text,
            imagePath: croppedFile.path,
            userProfile: userProfile ?? {}, // Pass userProfile
          ),
        ),
      );
    }
    setState(() => _isScanning = false);
  }

  Future<String> _processText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text.isNotEmpty
        ? recognizedText.text
        : "No text detected.";
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
      appBar: AppBar(
        title: Text("Scan Food Label"),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),
          if (_isScanning)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isScanning ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: Container(
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Scanning...",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            child: FloatingActionButton(
              onPressed: _isScanning ? null : _captureAndScan,
              backgroundColor: primaryColor,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
