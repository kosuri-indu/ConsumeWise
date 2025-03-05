// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

// class ScanningPage extends StatefulWidget {
//   @override
//   _ScanningPageState createState() => _ScanningPageState();
// }

// class _ScanningPageState extends State<ScanningPage> {
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   bool _isScanning = false;
//   String _scannedText = "Scan food label to extract details";

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     _cameraController = CameraController(cameras.first, ResolutionPreset.high);
//     await _cameraController!.initialize();
//     setState(() => _isCameraInitialized = true);
//   }

//   Future<void> _scanFoodLabel() async {
//     if (!_isCameraInitialized || _isScanning) return;

//     setState(() => _isScanning = true);

//     try {
//       XFile picture = await _cameraController!.takePicture();
//       final inputImage = InputImage.fromFilePath(picture.path);
//       final textRecognizer = GoogleMlKit.vision.textRecognizer();
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);

//       setState(() {
//         _scannedText = recognizedText.text.isNotEmpty
//             ? recognizedText.text
//             : "No text detected.";
//       });

//       textRecognizer.close();
//     } catch (e) {
//       setState(() => _scannedText = "Error: ${e.toString()}");
//     }

//     setState(() => _isScanning = false);
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Scan Food Label")),
//       body: Column(
//         children: [
//           _isCameraInitialized
//               ? AspectRatio(
//                   aspectRatio: _cameraController!.value.aspectRatio,
//                   child: CameraPreview(_cameraController!),
//                 )
//               : Center(child: CircularProgressIndicator()),
//           SizedBox(height: 10),
//           ElevatedButton.icon(
//             icon: Icon(Icons.camera),
//             label: Text("Scan"),
//             onPressed: _scanFoodLabel,
//           ),
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Text(
//               _scannedText,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
