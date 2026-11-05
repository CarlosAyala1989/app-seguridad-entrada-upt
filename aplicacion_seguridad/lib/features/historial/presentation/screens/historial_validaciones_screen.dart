import 'package:flutter/material.dart';

import '../../../../core/services/location_service.dart';
import '../../../incidencias/presentation/dialogs/registrar_incidencia_dialog.dart';
import '../../../turnos/data/models/turno_model.dart';
import '../../../turnos/data/services/turnos_service.dart';
import '../../data/models/registro_historial_model.dart';
import '../../data/services/historial_service.dart';

class HistorialValidacionesScreen extends StatefulWidget {
  final HistorialService? historialService;
  final TurnosService? turnosService;

  const HistorialValidacionesScreen({
    super.key,
    this.historialService,
    this.turnosService,
  });

  @override
  State<HistorialValidacionesScreen> createState() =>
      _HistorialValidacionesScreenState();
}

class _HistorialValidacionesScreenState
    extends State<HistorialValidacionesScreen> {
  late List<RegistroHistorialModel> _registros;
  String _filtroResultado = 'TODOS'; // 'TODOS', 'AUTORIZADO', 'DENEGADO'
  final TextEditingController _searchController = TextEditingController();
  String _busqueda = '';

  late final HistorialService _historialService;
  late final TurnosService _turnosService;

  bool _cargando = false;
  TurnoModel? _turnoActual;

  @override
  void initState() {
    super.initState();
    _historialService = widget.historialService ?? HistorialService();
    _turnosService = widget.turnosService ?? TurnosService();

    // Inicializamos con registros locales demostrativos para pruebas inmediatas y modo offline
    _registros = RegistroHistorialModel.obtenerRegistrosIniciales();

    _searchController.addListener(() {
      setState(() {
        _busqueda = _searchController.text.trim().toLowerCase();
      });
    });

    _cargarDatosRemotos();
  }

  Future<void> _cargarDatosRemotos() async {
    try {
      final turno = await _turnosService.consultarTurnoActual();
      if (mounted) setState(() => _turnoActual = turno);

      final ubicacion = await LocationService.obtenerUbicacionActual();
      final remotos = await _historialService.consultarIngresosRecientes(
        ubicacion: ubicacion,
        puntoAccesoCodigo: 'PUERTA-PRINCIPAL',
        turnoId: turno?.id,
      );

      if (mounted && remotos.isNotEmpty) {
        setState(() {
          _registros = remotos;
        });
      }
    } catch (_) {
      // Si la API remota no está accesible o se ejecuta en entorno de prueba sin backend,
      // se conservan los datos de la lista demostrativa inicial.
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RegistroHistorialModel> get _registrosFiltrados {
    return _registros.where((reg) {
      if (_filtroResultado == 'AUTORIZADO' && !reg.esAutorizado) return false;
      if (_filtroResultado == 'DENEGADO' && reg.esAutorizado) return false;

      if (_busqueda.isNotEmpty) {
        final nombre = (reg.nombreCompleto ?? '').toLowerCase();
        final codigo = (reg.codigoInstitucional ?? '').toLowerCase();
        final motivo = reg.motivoLegible.toLowerCase();
        final obs = (reg.observacion ?? '').toLowerCase();

        return nombre.contains(_busqueda) ||
            codigo.contains(_busqueda) ||
            motivo.contains(_busqueda) ||
            obs.contains(_busqueda);
      }
      return true;
    }).toList();
  }

  int get _totalAutorizados =>
      _registros.where((r) => r.esAutorizado).length;
  int get _totalDenegados =>
      _registros.where((r) => !r.esAutorizado).length;

  Future<void> _recargarHistorial() async {
    setState(() => _cargando = true);
    await _cargarDatosRemotos();
    if (!mounted) return;
    setState(() => _cargando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historial de validaciones actualizado'),
        backgroundColor: Color(0xFF0284C7),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _gestionarTurno() async {
    if (_turnoActual == null) {
      // Iniciar nuevo turno
      try {
        final ubicacion = await LocationService.obtenerUbicacionActual();
        final nuevoTurno = await _turnosService.iniciarTurno(ubicacion);
        if (!mounted) return;
        setState(() => _turnoActual = nuevoTurno);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Turno #${nuevoTurno.id} iniciado exitosamente.'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo iniciar el turno: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } else {
      // Cerrar turno activo
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('¿Cerrar turno activo?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Se cerrará el turno #${_turnoActual!.id}. Las siguientes validaciones no se vincularán a este turno.',
            style: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cerrar Turno', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmar == true) {
        try {
          await _turnosService.cerrarTurno(_turnoActual!.id);
          if (!mounted) return;
          setState(() => _turnoActual = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Turno cerrado correctamente.'),
              backgroundColor: Color(0xFF0284C7),
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo cerrar el turno: $e'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$min';
  }

  void _mostrarDetalles(RegistroHistorialModel reg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    reg.esAutorizado
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: reg.esAutorizado
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEF4444),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reg.esAutorizado
                              ? 'INGRESO PERMITIDO'
                              : 'INGRESO DENEGADO',
                          style: TextStyle(
                            color: reg.esAutorizado
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID Evento: ${reg.id}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 28),
              if (reg.esAutorizado && reg.nombreCompleto != null) ...[
                _buildInfoFila('Estudiante:', reg.nombreCompleto!),
                const SizedBox(height: 8),
                _buildInfoFila('Código UPT:', reg.codigoInstitucional ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoFila('Escuela:', reg.escuela ?? 'Comunidad Universitaria'),
                const SizedBox(height: 8),
              ],
              _buildInfoFila('Motivo:', reg.motivoLegible),
              const SizedBox(height: 8),
              _buildInfoFila('Punto de Acceso:', reg.puntoAccesoNombre),
              const SizedBox(height: 8),
              _buildInfoFila('Hora de registro:', _formatearHora(reg.fechaHora)),
              if (reg.turnoId != null) ...[
                const SizedBox(height: 8),
                _buildInfoFila('Turno ID:', '#${reg.turnoId}'),
              ],
              if (reg.observacion != null) ...[
                const SizedBox(height: 8),
                _buildInfoFila('Observación:', reg.observacion!),
              ],
              const SizedBox(height: 20),

              // Botón para registrar incidencia vinculada (Issue #16)
              if (reg.idNumerico != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      foregroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.report_problem_outlined, size: 18),
                    label: const Text('Registrar Incidencia'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      RegistrarIncidenciaDialog.mostrar(
                        context,
                        registroId: reg.idNumerico!,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar Detalle'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoFila(String label, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final registros = _registrosFiltrados;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Historial de Accesos Recientes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar historial',
            onPressed: _recargarHistorial,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de punto de control activo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Punto: Puerta Principal - Campus Capanique',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Botón de control de turno de guardia (Issue #18)
                InkWell(
                  onTap: _gestionarTurno,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _turnoActual != null
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _turnoActual != null
                            ? const Color(0xFF10B981)
                            : const Color(0xFF38BDF8),
                      ),
                    ),
                    child: Text(
                      _turnoActual != null
                          ? 'Turno #${_turnoActual!.id} (Activo)'
                          : 'Iniciar Turno',
                      style: TextStyle(
                        color: _turnoActual != null
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Resumen de Métricas del Turno
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTarjetaMetrica(
                    titulo: 'Total',
                    valor: '${_registros.length}',
                    color: const Color(0xFF38BDF8),
                    icono: Icons.qr_code_scanner,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarjetaMetrica(
                    titulo: 'Permitidos',
                    valor: '$_totalAutorizados',
                    color: const Color(0xFF4ADE80),
                    icono: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTarjetaMetrica(
                    titulo: 'Denegados',
                    valor: '$_totalDenegados',
                    color: const Color(0xFFF87171),
                    icono: Icons.cancel_outlined,
                  ),
                ),
              ],
            ),
          ),

          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar por código, nombre o motivo...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF94A3B8), size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
            ),
          ),

          // Filtros Rápidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFiltroChip('TODOS', 'Todos (${_registros.length})'),
                const SizedBox(width: 8),
                _buildFiltroChip('AUTORIZADO', 'Permitidos ($_totalAutorizados)'),
                const SizedBox(width: 8),
                _buildFiltroChip('DENEGADO', 'Denegados ($_totalDenegados)'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Lista de Registros
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  )
                : registros.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_outlined, size: 48, color: Color(0xFF475569)),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron validaciones',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: registros.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final reg = registros[index];
                          return _buildTarjetaHistorial(reg);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaMetrica({
    required String titulo,
    required String valor,
    required Color color,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(String clave, String label) {
    final seleccionado = _filtroResultado == clave;
    return ChoiceChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) {
        setState(() {
          _filtroResultado = clave;
        });
      },
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : const Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: const Color(0xFF0284C7),
      backgroundColor: const Color(0xFF1E293B),
      side: BorderSide(
        color: seleccionado ? const Color(0xFF0284C7) : const Color(0xFF334155),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _buildTarjetaHistorial(RegistroHistorialModel reg) {
    final esAutorizado = reg.esAutorizado;
    final color = esAutorizado
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return InkWell(
      onTap: () => _mostrarDetalles(reg),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: esAutorizado
                ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                : const Color(0xFFEF4444).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                esAutorizado
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reg.nombreCompleto ?? 'Identidad Protegida',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatearHora(reg.fechaHora),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Cód: ${reg.codigoInstitucional ?? 'N/A'}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          esAutorizado ? 'PERMITIDO' : 'DENEGADO',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reg.motivoLegible,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF475569), size: 18),
          ],
        ),
      ),
    );
  }
}
