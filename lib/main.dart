import 'package:flutter/material.dart';
import 'live_character_recognizer.dart';

void main() {
  runApp(const VoiceCraftApp());
}

class VoiceCraftApp extends StatelessWidget {
  const VoiceCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CharacterRecognizerScreen(),
    );
  }
}