import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/services/location_service.dart';
import '../../data/services/validacion_service.dart';
import 'resultado_validacion_screen.dart';

class EscanerQrScreen extends StatefulWidget {
  final String puntoAccesoCodigo;
  final String puntoAccesoNombre;
  final ValidacionService? validacionService;

  const EscanerQrScreen({
    super.key,
    this.puntoAccesoCodigo = 'PUERTA-PRINCIPAL',
    this.puntoAccesoNombre = 'Puerta Principal - Campus Capanique',
    this.validacionService,
  });

  @override
  State<EscanerQrScreen> createState() => _EscanerQrScreenState();
}

class _EscanerQrScreenState extends State<EscanerQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late final ValidacionService _validacionService;
  bool _procesando = false;
  String? _mensajeEstado;

  @override
  void initState() {
    super.initState();
    _validacionService = widget.validacionService ?? ValidacionService();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _procesarCodigo(String codigoQr) async {
    if (_procesando) return;

    final codigoLimpio = codigoQr.trim();
    if (codigoLimpio.isEmpty) return;

    setState(() {
      _procesando = true;
      _mensajeEstado = 'Obteniendo GPS y validando credencial...';
    });

    try {
      final ubicacion = await LocationService.obtenerUbicacionActual();

      final resultado = await _validacionService.validarIngreso(
        codigoQr: codigoLimpio,
        puntoAccesoCodigo: widget.puntoAccesoCodigo,
        ubicacion: ubicacion,
      );

      if (!mounted) return;

      setState(() {
        _mensajeEstado = null;
      });

      // Abre la pantalla de decisión clara
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultadoValidacionScreen(
            resultado: resultado,
            onEscanearSiguiente: () {},
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _procesando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _procesando = false;
        _mensajeEstado = null;
      });

      final mensaje = e.toString().replaceFirst('ApiException: ', '');
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text('Validación No Confirmada',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            mensaje,
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _abrirDialogoSimulacionManual() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Entrada Manual / Prueba de QR',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa o pega el contenido completo del QR (upt_qr_v1... u offline):',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'upt_qr_v1:eyJhbG...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            onPressed: () {
              final texto = controller.text.trim();
              Navigator.of(ctx).pop();
              if (texto.isNotEmpty) {
                _procesarCodigo(texto);
              }
            },
            child: const Text('Validar Código', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Escanear Credencial QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            tooltip: 'Linterna',
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android, color: Colors.white),
            tooltip: 'Cambiar cámara',
            onPressed: () => _scannerController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_alt_outlined, color: Color(0xFF38BDF8)),
            tooltip: 'Ingresar código de prueba',
            onPressed: _abrirDialogoSimulacionManual,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visor de Cámara con MobileScanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final valor = barcode.rawValue;
                if (valor != null && valor.isNotEmpty) {
                  _procesarCodigo(valor);
                  break;
                }
              }
            },
          ),

          // Overlay visual de escaneo
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _procesando
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF38BDF8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_procesando
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF38BDF8))
                        .withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Barra informativa superior: Puerta asignada
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.door_front_door_outlined,
                      color: Color(0xFF38BDF8), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.puntoAccesoNombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Punto: ${widget.puntoAccesoCodigo}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Indicador de procesamiento / carga
          if (_procesando)
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        _mensajeEstado ?? 'Validando...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
