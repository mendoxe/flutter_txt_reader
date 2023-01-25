import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:txt_reader/home/loading_widget.dart';

import '../camera/camera_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  bool _processing = false;
  RecognizedText? text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TXT Reader"),
      ),
      body: _processing
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(text?.text ?? "No Text"),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openRecognizer,
        child: const Icon(Icons.camera),
      ),
    );
  }

  Future<void> _openRecognizer() async {
    setState(() {
      _processing = true;
    });
    XFile? picture = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const CameraScaffold();
        },
      ),
    );

    if (picture == null) return;

    text = await _textRecognizer
        .processImage(InputImage.fromFilePath(picture.path));
    setState(() {
      _processing = false;
    });
  }
}
