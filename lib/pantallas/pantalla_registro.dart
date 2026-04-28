// Pantalla CORE: registro de una nueva recolección de leche.
// Realiza validaciones para detectar problemas comunes:
//   - Litros <= 0 (no permite guardar)
//   - Temperatura > 10°C (alerta de leche caliente)
//   - Densidad < 1.028 g/mL (posible adulteración con agua)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../modelos/recoleccion.dart';
import '../servicios/base_datos.dart';
import '../utiles/datos_predefinidos.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _claveFormulario = GlobalKey<FormState>();

  final _ctrlLitros = TextEditingController();
  final _ctrlTemperatura = TextEditingController();
  final _ctrlDensidad = TextEditingController();
  final _ctrlObservaciones = TextEditingController();

  String? _productorSeleccionado;
  bool _guardando = false;

  // Coordenadas GPS simuladas (en una app real se obtendrían con geolocator)
  final double _latitudSimulada = -12.0464;
  final double _longitudSimulada = -77.0428;

  @override
  void dispose() {
    _ctrlLitros.dispose();
    _ctrlTemperatura.dispose();
    _ctrlDensidad.dispose();
    _ctrlObservaciones.dispose();
    super.dispose();
  }

  // Verifica los valores críticos y muestra alerta si hay problemas.
  // Devuelve true si el usuario decide continuar de todas formas.
  Future<bool> _verificarCalidad(double temperatura, double densidad) async {
    final List<String> alertas = [];

    if (temperatura > 10) {
      alertas.add(
        '⚠️ Temperatura alta: ${temperatura.toStringAsFixed(1)}°C\n'
        'La leche debería estar por debajo de 10°C para conservarse bien.',
      );
    }

    if (densidad < 1.028) {
      alertas.add(
        '⚠️ Densidad baja: ${densidad.toStringAsFixed(3)} g/mL\n'
        'Posible adulteración con agua. Lo normal es entre 1.028 y 1.034 g/mL.',
      );
    }

    if (alertas.isEmpty) return true;

    // Si hay alertas, mostramos un diálogo claro y grande
    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 32),
            SizedBox(width: 8),
            Text('Atención', style: TextStyle(fontSize: 22)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...alertas.map(
              (a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(a, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Desea guardar el registro de todas formas?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CORREGIR', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(120, 48),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );

    return continuar ?? false;
  }

  // Guarda la recolección en la base de datos local
  Future<void> _guardar() async {
    if (!_claveFormulario.currentState!.validate()) return;

    if (_productorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un productor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final litros = double.parse(_ctrlLitros.text.replaceAll(',', '.'));
    final temperatura =
        double.parse(_ctrlTemperatura.text.replaceAll(',', '.'));
    final densidad = double.parse(_ctrlDensidad.text.replaceAll(',', '.'));

    // Validación de calidad
    final continuar = await _verificarCalidad(temperatura, densidad);
    if (!continuar) return;

    setState(() => _guardando = true);

    // Creamos el registro con UUID único.
    // El estado inicial siempre es "pendiente" porque la app es offline-first:
    // se guarda local primero y luego se sincroniza.
    final nueva = Recoleccion(
      id: const Uuid().v4(),
      nombreProductor: _productorSeleccionado!,
      litros: litros,
      fechaHora: DateTime.now(),
      latitud: _latitudSimulada,
      longitud: _longitudSimulada,
      temperatura: temperatura,
      densidad: densidad,
      observaciones: _ctrlObservaciones.text.trim().isEmpty
          ? null
          : _ctrlObservaciones.text.trim(),
      estado: 'pendiente',
      ruta: DatosPredefinidos.rutaDelDia,
    );

    await BaseDatos.instancia.insertarRecoleccion(nueva);

    if (!mounted) return;
    setState(() => _guardando = false);

    // Mensaje de éxito y volvemos al menú
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Registro guardado correctamente'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final fechaFormateada =
        DateFormat("dd/MM/yyyy 'a las' HH:mm", 'es_ES').format(ahora);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Recolección')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _claveFormulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de fecha y hora (automática)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Colors.blue, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha y hora',
                            style: TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                          Text(
                            fechaFormateada,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selector de productor (lista predefinida)
              const Text(
                'Productor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _productorSeleccionado,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, size: 28),
                  hintText: 'Seleccione un productor',
                ),
                items: DatosPredefinidos.productores
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (valor) =>
                    setState(() => _productorSeleccionado = valor),
                validator: (valor) =>
                    valor == null ? 'Seleccione un productor' : null,
              ),
              const SizedBox(height: 16),

              // Campo: Litros
              const Text(
                'Litros de leche',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ctrlLitros,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.opacity, size: 28),
                  hintText: 'Ej. 25.5',
                  suffixText: 'L',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingrese los litros';
                  }
                  final num = double.tryParse(valor.replaceAll(',', '.'));
                  if (num == null) return 'Número inválido';
                  if (num <= 0) return 'Los litros deben ser mayores a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Temperatura
              const Text(
                'Temperatura',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ctrlTemperatura,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.thermostat, size: 28),
                  hintText: 'Ej. 4.0',
                  suffixText: '°C',
                  helperText: 'Lo recomendable es ≤ 10°C',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingrese la temperatura';
                  }
                  final num = double.tryParse(valor.replaceAll(',', '.'));
                  if (num == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Densidad
              const Text(
                'Densidad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ctrlDensidad,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.science, size: 28),
                  hintText: 'Ej. 1.030',
                  suffixText: 'g/mL',
                  helperText: 'Lo normal es entre 1.028 y 1.034',
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingrese la densidad';
                  }
                  final num = double.tryParse(valor.replaceAll(',', '.'));
                  if (num == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Coordenadas GPS (simuladas)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS: ${_latitudSimulada.toStringAsFixed(4)}, '
                        '${_longitudSimulada.toStringAsFixed(4)} (simulado)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo: Observaciones (opcional)
              const Text(
                'Observaciones (opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _ctrlObservaciones,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notas adicionales...',
                ),
              ),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.save, size: 26),
                label: Text(_guardando ? 'GUARDANDO...' : 'GUARDAR REGISTRO'),
              ),
              const SizedBox(height: 12),

              // Botón cancelar
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
