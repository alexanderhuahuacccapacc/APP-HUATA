// Modelo simple que representa al usuario logueado.
// En este prototipo NO hay backend real:
// los usuarios están "hardcodeados" en el servicio de autenticación.

class Usuario {
  final String usuario;
  final String nombre;
  final String rol; // "administrador" o "acopiador"

  Usuario({
    required this.usuario,
    required this.nombre,
    required this.rol,
  });
}
