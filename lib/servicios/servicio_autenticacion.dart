// Servicio de autenticación SIMULADA.
// No hay backend real: los usuarios y contraseñas están "hardcodeados".
// La sesión activa se guarda con SharedPreferences para que el usuario
// no tenga que loguearse cada vez que abre la app.

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/usuario.dart';

class ServicioAutenticacion {
  // Lista mock de usuarios válidos.
  // En un sistema real esto vendría de un servidor.
  static final List<Map<String, String>> _usuariosMock = [
    {
      'usuario': 'admin',
      'contrasena': '1234',
      'nombre': 'Administrador',
      'rol': 'administrador',
    },
    {
      'usuario': 'acopiador',
      'contrasena': '1234',
      'nombre': 'Juan Pérez',
      'rol': 'acopiador',
    },
    {
      'usuario': 'maria',
      'contrasena': '1234',
      'nombre': 'María López',
      'rol': 'acopiador',
    },
  ];

  // Intenta iniciar sesión.
  // Si las credenciales son correctas, guarda la sesión y retorna el Usuario.
  // Si no, retorna null.
  Future<Usuario?> iniciarSesion(String usuario, String contrasena) async {
    // Pequeño delay simulado para que se sienta como una llamada de red
    await Future.delayed(const Duration(milliseconds: 500));

    for (final u in _usuariosMock) {
      if (u['usuario'] == usuario && u['contrasena'] == contrasena) {
        final encontrado = Usuario(
          usuario: u['usuario']!,
          nombre: u['nombre']!,
          rol: u['rol']!,
        );
        await _guardarSesion(encontrado);
        return encontrado;
      }
    }
    return null;
  }

  // Guarda al usuario logueado en SharedPreferences
  Future<void> _guardarSesion(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', usuario.usuario);
    await prefs.setString('nombre', usuario.nombre);
    await prefs.setString('rol', usuario.rol);
  }

  // Verifica si existe una sesión activa guardada
  Future<bool> haySesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario') != null;
  }

  // Devuelve el usuario actualmente logueado (si existe)
  Future<Usuario?> obtenerUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    final usuario = prefs.getString('usuario');
    if (usuario == null) return null;
    return Usuario(
      usuario: usuario,
      nombre: prefs.getString('nombre') ?? '',
      rol: prefs.getString('rol') ?? 'acopiador',
    );
  }

  // Cierra la sesión (borra los datos guardados)
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    await prefs.remove('nombre');
    await prefs.remove('rol');
  }
}
