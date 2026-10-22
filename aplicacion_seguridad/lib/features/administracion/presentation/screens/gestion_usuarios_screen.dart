import 'package:flutter/material.dart';

class UsuarioPersonalModel {
  final String id;
  final String nombres;
  final String apellidos;
  final String usuario;
  final String correo;
  final String rol; // 'GUARDIA' o 'ADMINISTRADOR'
  final String puertaAsignada;
  final String estado; // 'ACTIVO' o 'INACTIVO'

  const UsuarioPersonalModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.usuario,
    required this.correo,
    required this.rol,
    required this.puertaAsignada,
    this.estado = 'ACTIVO',
  });

  String get nombreCompleto => '$nombres $apellidos'.trim();
  bool get esAdmin => rol.toUpperCase() == 'ADMINISTRADOR';
}

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  final List<UsuarioPersonalModel> _usuarios = [
    const UsuarioPersonalModel(
      id: '1',
      nombres: 'Carlos Alberto',
      apellidos: 'Ayala Ramos',
      usuario: 'ca2022074266',
      correo: 'ca2022074266@virtual.upt.pe',
      rol: 'ADMINISTRADOR',
      puertaAsignada: 'Todas las sedes',
      estado: 'ACTIVO',
    ),
    const UsuarioPersonalModel(
      id: '2',
      nombres: 'Jefferson',
      apellidos: 'Rosas Chambilla',
      usuario: 'jr2021072618',
      correo: 'jr2021072618@virtual.upt.pe',
      rol: 'GUARDIA',
      puertaAsignada: 'Puerta Principal - Campus Capanique',
      estado: 'ACTIVO',
    ),
    const UsuarioPersonalModel(
      id: '3',
      nombres: 'Marcos',
      apellidos: 'Vargas Flores',
      usuario: 'guardia_pinto',
      correo: 'seguridad.pinto@virtual.upt.pe',
      rol: 'GUARDIA',
      puertaAsignada: 'Puerta 2 - Av. Pinto',
      estado: 'ACTIVO',
    ),
  ];

  String _filtroRol = 'TODOS';

  void _abrirModalRegistro([UsuarioPersonalModel? usuarioAEditar]) {
    final formKey = GlobalKey<FormState>();
    final nombresCtrl = TextEditingController(text: usuarioAEditar?.nombres ?? '');
    final apellidosCtrl =
        TextEditingController(text: usuarioAEditar?.apellidos ?? '');
    final usuarioCtrl = TextEditingController(text: usuarioAEditar?.usuario ?? '');
    final correoCtrl = TextEditingController(text: usuarioAEditar?.correo ?? '');
    final claveCtrl = TextEditingController();
    String rolSeleccionado = usuarioAEditar?.rol ?? 'GUARDIA';
    String puertaSeleccionada =
        usuarioAEditar?.puertaAsignada ?? 'Puerta Principal - Campus Capanique';

    final puertasDisponibles = [
      'Puerta Principal - Campus Capanique',
      'Puerta 2 - Av. Pinto',
      'Puerta Peatonal Este',
      'Acceso Vehicular Norte',
      'Todas las sedes',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            usuarioAEditar == null
                                ? 'Registrar Nuevo Usuario'
                                : 'Editar Usuario',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Selector de Rol
                      const Text(
                        'Tipo de Rol:',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Guardia de Seguridad'),
                              selected: rolSeleccionado == 'GUARDIA',
                              selectedColor: const Color(0xFF0284C7),
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: rolSeleccionado == 'GUARDIA'
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                if (val) setModalState(() => rolSeleccionado = 'GUARDIA');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Administrador'),
                              selected: rolSeleccionado == 'ADMINISTRADOR',
                              selectedColor: const Color(0xFF7C3AED),
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: rolSeleccionado == 'ADMINISTRADOR'
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    rolSeleccionado = 'ADMINISTRADOR';
                                    puertaSeleccionada = 'Todas las sedes';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nombres y Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: _CampoTextoModal(
                              controller: nombresCtrl,
                              label: 'Nombres',
                              hint: 'Ej. Juan',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Obligatorio'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CampoTextoModal(
                              controller: apellidosCtrl,
                              label: 'Apellidos',
                              hint: 'Ej. Pérez',
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Obligatorio'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Usuario y Correo
                      _CampoTextoModal(
                        controller: usuarioCtrl,
                        label: 'Usuario / Código',
                        hint: 'Ej. 2024010203 o guardia_central',
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa un usuario'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      _CampoTextoModal(
                        controller: correoCtrl,
                        label: 'Correo Institucional',
                        hint: 'usuario@virtual.upt.pe',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa un correo institucional';
                          }
                          if (!v.contains('@')) {
                            return 'Formato de correo no válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      _CampoTextoModal(
                        controller: claveCtrl,
                        label: usuarioAEditar == null
                            ? 'Contraseña Inicial'
                            : 'Nueva Contraseña (opcional)',
                        hint: 'Mínimo 6 caracteres',
                        obscureText: true,
                        validator: (v) {
                          if (usuarioAEditar == null && (v == null || v.length < 6)) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Puerta asignada (para rol Guardia)
                      if (rolSeleccionado == 'GUARDIA') ...[
                        const Text(
                          'Punto de Control Asignado:',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: puertaSeleccionada,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1E293B),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              items: puertasDisponibles.map((p) {
                                return DropdownMenuItem(value: p, child: Text(p));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => puertaSeleccionada = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        const SizedBox(height: 8),
                      ],

                      // Botón Guardar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final nuevoUsuario = UsuarioPersonalModel(
                            id: usuarioAEditar?.id ??
                                DateTime.now().millisecondsSinceEpoch.toString(),
                            nombres: nombresCtrl.text.trim(),
                            apellidos: apellidosCtrl.text.trim(),
                            usuario: usuarioCtrl.text.trim(),
                            correo: correoCtrl.text.trim(),
                            rol: rolSeleccionado,
                            puertaAsignada: rolSeleccionado == 'ADMINISTRADOR'
                                ? 'Todas las sedes'
                                : puertaSeleccionada,
                            estado: 'ACTIVO',
                          );

                          setState(() {
                            if (usuarioAEditar != null) {
                              final idx = _usuarios.indexWhere(
                                  (u) => u.id == usuarioAEditar.id);
                              if (idx != -1) _usuarios[idx] = nuevoUsuario;
                            } else {
                              _usuarios.insert(0, nuevoUsuario);
                            }
                          });

                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF16A34A),
                              content: Text(
                                'Usuario ${nuevoUsuario.nombreCompleto} (${nuevoUsuario.rol}) guardado correctamente.',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          usuarioAEditar == null
                              ? 'Crear y Habilitar Usuario'
                              : 'Guardar Cambios',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuariosFiltrados = _usuarios.where((u) {
      if (_filtroRol == 'TODOS') return true;
      return u.rol == _filtroRol;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Gestión de Personal y Usuarios',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _abrirModalRegistro(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros rápidos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              child: Row(
                children: [
                  const Text(
                    'Filtrar:',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  _ChipFiltro(
                    label: 'Todos',
                    seleccionado: _filtroRol == 'TODOS',
                    onTap: () => setState(() => _filtroRol = 'TODOS'),
                  ),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                    label: 'Guardias',
                    seleccionado: _filtroRol == 'GUARDIA',
                    onTap: () => setState(() => _filtroRol = 'GUARDIA'),
                  ),
                  const SizedBox(width: 8),
                  _ChipFiltro(
                    label: 'Admins',
                    seleccionado: _filtroRol == 'ADMINISTRADOR',
                    onTap: () => setState(() => _filtroRol = 'ADMINISTRADOR'),
                  ),
                ],
              ),
            ),

            // Lista de usuarios
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: usuariosFiltrados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final u = usuariosFiltrados[index];
                  final esAdmin = u.esAdmin;
                  final colorRol = esAdmin
                      ? const Color(0xFFA855F7) // Púrpura Admin
                      : const Color(0xFF38BDF8); // Azul Guardia

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorRol.withValues(alpha: 0.2),
                          child: Icon(
                            esAdmin ? Icons.admin_panel_settings : Icons.shield,
                            color: colorRol,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      u.nombreCompleto,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: colorRol.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: colorRol),
                                    ),
                                    child: Text(
                                      u.rol,
                                      style: TextStyle(
                                        color: colorRol,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Usuario: ${u.usuario} · ${u.correo}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.door_front_door_outlined,
                                      size: 14, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      u.puertaAsignada,
                                      style: const TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF0284C7) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? const Color(0xFF38BDF8) : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: seleccionado ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CampoTextoModal extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CampoTextoModal({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      ],
    );
  }
}
