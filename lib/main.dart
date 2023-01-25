import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:txt_reader/camera/camera_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TXT Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

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
      body: Center(
        child: _processing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset('assets/lotties/loading.json'),
                  ),
                  const SizedBox(width: 100),
                  const Text("loading..."),
                ],
              )
            : Text(text?.text ?? "No Text"),
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
