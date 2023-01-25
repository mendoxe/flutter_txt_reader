import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:txt_reader/home/loading_widget.dart';

import '../camera/camera_scaffold.dart';

enum Recognizer { text, barcode }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _processing = false;
  String? _text;
  Recognizer _recognizer = Recognizer.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TXT Reader"),
        actions: [
          CupertinoSlidingSegmentedControl<Recognizer>(
              groupValue: _recognizer,
              backgroundColor: CupertinoColors.systemGrey3,
              thumbColor: Colors.blue,
              children: {
                Recognizer.text: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    "Text",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ),
                Recognizer.barcode: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    "Barcode",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ),
              },
              onValueChanged: ((value) {
                if (value != null) {
                  setState(() {
                    _recognizer = value;
                  });
                }
              })),
        ],
      ),
      body: _processing
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_text ?? "No Text"),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recognizer == Recognizer.barcode
            ? _openBarcodeReader
            : _openRecognizer,
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

    RecognizedText recognizedText = await _textRecognizer
        .processImage(InputImage.fromFilePath(picture.path));
    setState(() {
      _text = recognizedText.text;
      _processing = false;
    });
  }

  Future<void> _openBarcodeReader() async {
    setState(() {
      _processing = true;
      _text = null;
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

    var barcodes = await _barcodeScanner
        .processImage(InputImage.fromFilePath(picture.path));

    log(barcodes.length.toString());

    if (barcodes.isEmpty) {
      setState(() {
        _processing = false;
      });
      return;
    }

    setState(() {
      _text = barcodes.first.rawValue;
      _processing = false;
    });
  }
}
