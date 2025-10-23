import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class CharacterRecognizerScreen extends StatefulWidget {
  const CharacterRecognizerScreen({super.key});

  @override
  State<CharacterRecognizerScreen> createState() => _CharacterRecognizerScreenState();
}

class _CharacterRecognizerScreenState extends State<CharacterRecognizerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  CameraLensDirection _currentLens = CameraLensDirection.front;

  bool _isLoading = false;
  String _prediction = '';
  final String apiKey = "MY_API_KEY";

  @override
  void initState() {
    super.initState();
    _initializeCamera(_currentLens);
  }

  Future<void> _initializeCamera(CameraLensDirection direction) async {
    _cameras = await availableCameras();
    final selectedCamera = _cameras!.firstWhere(
      (cam) => cam.lensDirection == direction,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(selectedCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void _toggleCamera() async {
    _currentLens =
        _currentLens == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;
    await _cameraController?.dispose();
    await _initializeCamera(_currentLens);
  }

  Future<void> _captureAndPredict() async {
    if (_isLoading || !_cameraController!.value.isInitialized) return;

    try {
      setState(() {
        _isLoading = true;
        _prediction = "⏳ Analyzing...";
      });

      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final uri = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey",
      );

      final body = jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": "What alphabet does this hand gesture represent in Indian Sign Language? Respond with a single capital letter. If it's not ISL, say it's not."
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ]
      });

      final response = await http
          .post(uri, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final parts = decoded["candidates"][0]["content"]["parts"];

        if (parts.isEmpty || parts[0]["text"].trim().isEmpty) {
          setState(() => _prediction = "⚠️ This doesn't seem like an Indian Sign Language gesture.");
        } else {
          final text = parts[0]["text"].trim();
          setState(() => _prediction = "✅ Prediction: $text");
        }
      } else if (response.statusCode == 429) {
        setState(() => _prediction = "⚠️ Quota exceeded. Try again later.");
      } else {
        setState(() => _prediction = "❌ Error ${response.statusCode}: Prediction failed.");
      }
    } on TimeoutException {
      setState(() => _prediction = "⏱️ Request timed out. Try again.");
    } on SocketException {
      setState(() => _prediction = "🚫 No internet connection.");
    } catch (e) {
      setState(() => _prediction = "❌ Unexpected error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: IconButton(
              icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
              onPressed: _toggleCamera,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cameraHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E25),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Live Character Recognizer",
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: cameraHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black,
                ),
                child: _buildCameraPreview(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _prediction.isEmpty ? "📷 Capture to see prediction..." : _prediction,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _toggleButton("Character", _captureAndPredict),
                _toggleButton("Sentence", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🛠️ Sentence mode coming soon...")),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _captureAndPredict,
              child: Container(
                height: 70,
                width: 70,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A5AE0), Color(0xFF4AD8D6)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
