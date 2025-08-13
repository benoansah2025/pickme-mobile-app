import 'dart:io';

import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';

class FaceCapturing extends StatefulWidget {
  const FaceCapturing({super.key});

  @override
  State<FaceCapturing> createState() => _FaceCapturingState();
}

class _FaceCapturingState extends State<FaceCapturing> {
  late FaceCameraController _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized(); //Add this
    _controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        Navigator.pop(context, image!.path);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartFaceCamera(
        message: 'Center your face in the square',
        controller: _controller,
      ),
    );
  }
}
