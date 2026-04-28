// Punto de entrada principal de la aplicación.
// Aquí se decide si el usuario debe ir al login o directamente al menú,
// dependiendo de si tiene una sesión activa guardada localmente.

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'servicios/servicio_autenticacion.dart';
import 'pantallas/pantalla_login.dart';
import 'pantallas/pantalla_menu.dart';

void main() async {
  // Asegura que Flutter esté inicializado antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el formato de fechas en español
  await initializeDateFormatting('es_ES', null);

  runApp(const AplicacionRecojoLeche());
}

class AplicacionRecojoLeche extends StatelessWidget {
  const AplicacionRecojoLeche({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recojo de Leche',
      debugShowCheckedModeBanner: false,

      // Tema visual: colores cálidos, botones grandes, texto legible.
      // Pensado para usuarios rurales con baja alfabetización digital.
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Verde fuerte
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Roboto',

        // Texto en general más grande de lo normal
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        // Botones grandes y fáciles de presionar
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Campos de texto con bordes claros
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF2E7D32),
              width: 2,
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      // La pantalla inicial se decide dinámicamente
      home: const PantallaInicial(),
    );
  }
}

/// Pantalla que decide a dónde enviar al usuario al abrir la app.
/// Si hay sesión guardada -> Menú principal.
/// Si no hay sesión -> Login.
class PantallaInicial extends StatefulWidget {
  const PantallaInicial({super.key});

  @override
  State<PantallaInicial> createState() => _PantallaInicialState();
}

class _PantallaInicialState extends State<PantallaInicial> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  // Revisa si ya hay un usuario logueado previamente
  Future<void> _verificarSesion() async {
    final servicio = ServicioAutenticacion();
    final haySesion = await servicio.haySesionActiva();

    // Pequeño retraso para mostrar la pantalla de bienvenida
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (haySesion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaMenu()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga / bienvenida
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_drink, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Recojo de Leche',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
