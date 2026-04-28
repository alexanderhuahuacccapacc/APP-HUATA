// Pantalla del menú principal.
// Muestra los accesos a las funciones principales según el rol del usuario.
// El acopiador puede registrar y ver historial.
// El administrador ve además el botón de sincronización.

import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/servicio_autenticacion.dart';
import '../servicios/base_datos.dart';
import '../utiles/datos_predefinidos.dart';
import 'pantalla_login.dart';
import 'pantalla_registro.dart';
import 'pantalla_historial.dart';
import 'pantalla_sincronizacion.dart';

class PantallaMenu extends StatefulWidget {
  const PantallaMenu({super.key});

  @override
  State<PantallaMenu> createState() => _PantallaMenuState();
}

class _PantallaMenuState extends State<PantallaMenu> {
  Usuario? _usuario;
  int _pendientes = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Carga el usuario logueado y cuenta los registros pendientes
  Future<void> _cargarDatos() async {
    final servicio = ServicioAutenticacion();
    final usuario = await servicio.obtenerUsuarioActual();
    final pendientes = await BaseDatos.instancia.contarPendientes();

    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _pendientes = pendientes;
    });
  }

  // Cierra sesión y vuelve al login
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Está seguro que desea salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SALIR'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await ServicioAutenticacion().cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PantallaLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esAdmin = _usuario?.rol == 'administrador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta con saludo al usuario
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${_usuario?.nombre ?? ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _usuario?.rol == 'administrador'
                                  ? 'Administrador'
                                  : 'Acopiador',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Información de la ruta del día
                  Row(
                    children: [
                      const Icon(Icons.route, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DatosPredefinidos.rutaDelDia,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Aviso de pendientes (si hay)
            if (_pendientes > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tiene $_pendientes registro(s) pendiente(s) por sincronizar',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón principal: registrar nueva recolección
            _BotonMenu(
              icono: Icons.add_circle,
              titulo: 'NUEVA RECOLECCIÓN',
              subtitulo: 'Registrar leche recibida',
              color: const Color(0xFF2E7D32),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaRegistro()),
                );
                _cargarDatos(); // refresca el contador al volver
              },
            ),
            const SizedBox(height: 14),

            // Botón: ver historial
            _BotonMenu(
              icono: Icons.list_alt,
              titulo: 'HISTORIAL',
              subtitulo: 'Ver registros guardados',
              color: Colors.blue.shade700,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantallaHistorial()),
                );
                _cargarDatos();
              },
            ),
            const SizedBox(height: 14),

            // Botón: sincronizar (visible para todos, pero el admin podría tener más opciones)
            _BotonMenu(
              icono: Icons.sync,
              titulo: 'SINCRONIZAR',
              subtitulo: esAdmin
                  ? 'Enviar registros al servidor (Admin)'
                  : 'Enviar registros al servidor',
              color: Colors.orange.shade700,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PantallaSincronizacion(),
                  ),
                );
                _cargarDatos();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para los botones grandes del menú
class _BotonMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _BotonMenu({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icono, size: 48, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
