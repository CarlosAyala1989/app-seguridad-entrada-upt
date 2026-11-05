import 'package:flutter/material.dart';

import '../../../incidencias/presentation/dialogs/registrar_incidencia_dialog.dart';
import '../../data/models/resultado_validacion_model.dart';

class ResultadoValidacionScreen extends StatelessWidget {
  final ResultadoValidacionModel resultado;
  final VoidCallback? onEscanearSiguiente;

  const ResultadoValidacionScreen({
    super.key,
    required this.resultado,
    this.onEscanearSiguiente,
  });

  String _describirMotivo(String motivo) {
    switch (motivo) {
      case 'ACCESO_AUTORIZADO':
        return 'Credencial válida y activa dentro del horario permitido.';
      case 'CREDENCIAL_YA_UTILIZADA':
        return 'Este código QR ya fue utilizado anteriormente para ingresar.';
      case 'CREDENCIAL_EXPIRADA':
      case 'QR_EXPIRADO':
        return 'El código QR ha expirado. El estudiante debe generar uno nuevo.';
      case 'FUERA_DE_ZONA':
      case 'GEOCERCA_INVALIDA':
        return 'La credencial se generó fuera de la ubicación permitida de la universidad.';
      case 'USUARIO_INACTIVO':
      case 'USUARIO_BLOQUEADO':
        return 'El usuario se encuentra temporalmente inhabilitado o bloqueado.';
      case 'FUERA_HORARIO_PERMITIDO':
      case 'REGLA_ACCESO_DENEGADA':
        return 'El ingreso no está permitido para este rol o en el horario actual.';
      case 'DATOS_IDENTIDAD_INCOMPLETOS':
        return 'Faltan datos institucionales mínimos para validar la identidad.';
      default:
        return resultado.mensaje.isNotEmpty
            ? resultado.mensaje
            : 'No se cumplen las políticas institucionales de acceso.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final autorizado = resultado.esAutorizado;
    final colorPrincipal = autorizado
        ? const Color(0xFF22C55E) // Verde esmeralda
        : const Color(0xFFEF4444); // Rojo carmesí

    final identidad = resultado.identidad;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          autorizado ? 'Acceso Autorizado' : 'Acceso Denegado',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono de estado grande y animado visualmente
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorPrincipal.withValues(alpha: 0.15),
                    border: Border.all(color: colorPrincipal, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: colorPrincipal.withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    autorizado ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: colorPrincipal,
                    size: 58,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Título de Decisión Claro (US-09 e Issue #9)
              Text(
                autorizado ? 'INGRESO PERMITIDO' : 'INGRESO NO PERMITIDO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: colorPrincipal,
                ),
              ),

              const SizedBox(height: 8),

              // Mensaje del servidor
              Text(
                _describirMotivo(resultado.motivo),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBD5E1),
                  height: 1.4,
                ),
              ),

              // Acción sugerida ante la decisión (Issue #15)
              if (resultado.accionSugerida != null &&
                  resultado.accionSugerida!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF475569)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: Color(0xFFFBBF24), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          resultado.accionSugerida!,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Tarjeta de Identidad (Sólo si está AUTORIZADO - Issue #24)
              if (autorizado && identidad != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: (identidad.fotoUrl != null &&
                                      identidad.fotoUrl!.isNotEmpty)
                                  ? Image.network(
                                      identidad.fotoUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF38BDF8),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        color: const Color(0xFF334155),
                                        child: const Icon(
                                          Icons.person,
                                          size: 36,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF0284C7)
                                          .withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.person,
                                        size: 36,
                                        color: Color(0xFF38BDF8),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  identidad.nombreCompleto,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cód: ${identidad.codigoInstitucional}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF334155), height: 28),
                      if (identidad.escuela != null &&
                          identidad.escuela!.isNotEmpty) ...[
                        _ItemDato(
                          etiqueta: 'Escuela / Carrera:',
                          valor: identidad.escuela!,
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (identidad.estadoAcademico != null) ...[
                        _ItemDato(
                          etiqueta: 'Estado Académico:',
                          valor: identidad.estadoAcademico!,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _ItemDato(
                        etiqueta: 'Tipo de usuario:',
                        valor: identidad.tiposUsuario.join(', '),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tarjeta de causa si está DENEGADO (Issue #15)
              if (!autorizado) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF991B1B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFF87171), size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Causa de denegación:',
                              style: TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              resultado.mensaje,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Información del punto y registro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined,
                            color: Color(0xFF94A3B8), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          resultado.puntoAccesoNombre,
                          style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '${resultado.registradoEn.hour.toString().padLeft(2, '0')}:${resultado.registradoEn.minute.toString().padLeft(2, '0')}:${resultado.registradoEn.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón para Registrar Incidencia (Issue #16)
              if (resultado.registroId != null) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    RegistrarIncidenciaDialog.mostrar(
                      context,
                      registroId: resultado.registroId!,
                    );
                  },
                  icon: const Icon(Icons.report_problem_outlined,
                      color: Color(0xFFF59E0B), size: 20),
                  label: const Text(
                    'Registrar Incidencia de esta Validación',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Botón principal de acción
              ElevatedButton.icon(
                onPressed: () {
                  if (onEscanearSiguiente != null) {
                    onEscanearSiguiente!();
                  }
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  'Validar Siguiente Credencial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _ItemDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _ItemDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        Text(
          valor,
          style: const TextStyle(
            color: Color(0xFFF1F5F9),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
