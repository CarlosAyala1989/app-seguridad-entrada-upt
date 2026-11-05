import 'package:flutter/material.dart';

import '../../data/models/incidencia_model.dart';
import '../../data/services/incidencias_service.dart';

class RegistrarIncidenciaDialog extends StatefulWidget {
  final int registroId;
  final IncidenciasService? incidenciasService;

  const RegistrarIncidenciaDialog({
    super.key,
    required this.registroId,
    this.incidenciasService,
  });

  static Future<IncidenciaModel?> mostrar(
    BuildContext context, {
    required int registroId,
    IncidenciasService? service,
  }) {
    return showModalBottomSheet<IncidenciaModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RegistrarIncidenciaDialog(
        registroId: registroId,
        incidenciasService: service,
      ),
    );
  }

  @override
  State<RegistrarIncidenciaDialog> createState() =>
      _RegistrarIncidenciaDialogState();
}

class _RegistrarIncidenciaDialogState extends State<RegistrarIncidenciaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _observacionController = TextEditingController();

  String _tipoSeleccionado = 'PROBLEMA_QR';
  bool _enviando = false;
  String? _error;

  late final IncidenciasService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.incidenciasService ?? IncidenciasService();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _guardarIncidencia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      final res = await _service.registrarIncidencia(
        registroId: widget.registroId,
        tipo: _tipoSeleccionado,
        observacion: _observacionController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(res);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidencia #${res.id} registrada correctamente.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = e.toString().replaceFirst('ApiException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.report_problem_rounded,
                      color: Color(0xFFF59E0B), size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Registrar Incidencia (Decisión #${widget.registroId})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Vincula una observación a esta validación. La incidencia no modifica la autorización pero queda registrada en auditoría.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 18),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const Text(
                'Tipo de Incidencia:',
                style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _tipoSeleccionado,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: const [
                      DropdownMenuItem(
                        value: 'PROBLEMA_QR',
                        child: Text('Problema con código QR o pantalla'),
                      ),
                      DropdownMenuItem(
                        value: 'DOCUMENTO_NO_COINCIDE',
                        child: Text('Documento físico no coincide con identidad'),
                      ),
                      DropdownMenuItem(
                        value: 'SUPLANTACION',
                        child: Text('Sospecha de suplantación de identidad'),
                      ),
                      DropdownMenuItem(
                        value: 'OTRA',
                        child: Text('Otra incidencia operativa'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _tipoSeleccionado = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Observación detallada (10 a 1000 caracteres):',
                style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observacionController,
                maxLines: 4,
                maxLength: 1000,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe objetivamente los hechos observados...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0284C7)),
                  ),
                ),
                validator: (val) {
                  final texto = (val ?? '').trim();
                  if (texto.isEmpty) {
                    return 'Ingresa la observación de la incidencia.';
                  }
                  if (texto.length < 10) {
                    return 'La observación debe tener al menos 10 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _enviando ? null : _guardarIncidencia,
                icon: _enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  _enviando ? 'Enviando...' : 'Guardar Incidencia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
