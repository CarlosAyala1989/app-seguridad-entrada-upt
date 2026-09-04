import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(CameraSmokeApp(cameras: cameras));
}

class CameraSmokeApp extends StatelessWidget {
  const CameraSmokeApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraSmokePage(cameras: cameras),
    );
  }
}

class CameraSmokePage extends StatefulWidget {
  const CameraSmokePage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<CameraSmokePage> createState() => _CameraSmokePageState();
}

class _CameraSmokePageState extends State<CameraSmokePage> {
  CameraController? controller;
  String? error;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() => error = 'No se detectó una cámara disponible.');
      return;
    }
    final next = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await next.initialize();
      if (!mounted) return;
      setState(() => controller = next);
    } on CameraException catch (exception) {
      await next.dispose();
      if (mounted) setState(() => error = exception.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter · prueba de cámara')),
      body: Center(
        child: error != null
            ? Text(error!, textAlign: TextAlign.center)
            : current == null || !current.value.isInitialized
                ? const CircularProgressIndicator()
                : CameraPreview(current),
      ),
    );
  }
}
