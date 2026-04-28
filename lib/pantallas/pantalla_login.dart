// Pantalla de inicio de sesión.
// Usa el ServicioAutenticacion para validar usuario y contraseña
// contra una lista hardcodeada (no hay backend real).

import 'package:flutter/material.dart';

import '../servicios/servicio_autenticacion.dart';
import 'pantalla_menu.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _claveFormulario = GlobalKey<FormState>();
  final _ctrlUsuario = TextEditingController();
  final _ctrlContrasena = TextEditingController();
  final _servicioAuth = ServicioAutenticacion();

  bool _cargando = false;
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _ctrlUsuario.dispose();
    _ctrlContrasena.dispose();
    super.dispose();
  }

  // Intenta loguear al usuario
  Future<void> _ingresar() async {
    if (!_claveFormulario.currentState!.validate()) return;

    setState(() => _cargando = true);

    final usuario = await _servicioAuth.iniciarSesion(
      _ctrlUsuario.text.trim(),
      _ctrlContrasena.text.trim(),
    );

    if (!mounted) return;
    setState(() => _cargando = false);

    if (usuario != null) {
      // Login correcto -> ir al menú principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaMenu()),
      );
    } else {
      // Credenciales incorrectas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _claveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo / icono grande
                const Icon(
                  Icons.local_drink,
                  size: 90,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Recojo de Leche',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Inicie sesión para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Campo usuario
                TextFormField(
                  controller: _ctrlUsuario,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person, size: 28),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingrese su usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo contraseña
                TextFormField(
                  controller: _ctrlContrasena,
                  obscureText: _ocultarContrasena,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, size: 28),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _ocultarContrasena = !_ocultarContrasena);
                      },
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botón ingresar
                ElevatedButton(
                  onPressed: _cargando ? null : _ingresar,
                  child: _cargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('INGRESAR'),
                ),
                const SizedBox(height: 24),

                // Pista de usuarios disponibles (solo para el prototipo)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usuarios de prueba:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('• admin / 1234 (Administrador)'),
                      Text('• acopiador / 1234 (Acopiador)'),
                      Text('• maria / 1234 (Acopiador)'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
