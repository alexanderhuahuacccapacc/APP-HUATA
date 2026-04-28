// Pantalla de historial.
// Muestra todas las recolecciones guardadas localmente,
// con un indicador visual del estado (pendiente / sincronizado).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modelos/recoleccion.dart';
import '../servicios/base_datos.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  List<Recoleccion> _registros = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await BaseDatos.instancia.obtenerTodas();
    if (!mounted) return;
    setState(() {
      _registros = lista;
      _cargando = false;
    });
  }

  // Muestra el detalle completo de un registro
  void _mostrarDetalle(Recoleccion r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DetalleRecoleccion(recoleccion: r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? _mensajeVacio()
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _registros.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _ItemHistorial(
                          recoleccion: _registros[i],
                          onTap: () => _mostrarDetalle(_registros[i]),
                        ),
                  ),
                ),
    );
  }

  Widget _mensajeVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No hay registros guardados',
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use el botón "Nueva Recolección" para registrar.',
              style: TextStyle(fontSize: 14, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para cada item del historial
class _ItemHistorial extends StatelessWidget {
  final Recoleccion recoleccion;
  final VoidCallback onTap;

  const _ItemHistorial({required this.recoleccion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final esPendiente = recoleccion.estado == 'pendiente';
    final colorEstado = esPendiente ? Colors.orange : Colors.green;
    final iconoEstado = esPendiente ? Icons.cloud_off : Icons.cloud_done;
    final textoEstado = esPendiente ? 'Pendiente' : 'Sincronizado';

    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(recoleccion.fechaHora);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // Indicador circular grande con el estado
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(iconoEstado, color: colorEstado, size: 28),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recoleccion.nombreProductor,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${recoleccion.litros.toStringAsFixed(1)} L  •  $fecha',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      textoEstado,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorEstado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Hoja inferior con el detalle del registro
class _DetalleRecoleccion extends StatelessWidget {
  final Recoleccion recoleccion;

  const _DetalleRecoleccion({required this.recoleccion});

  @override
  Widget build(BuildContext context) {
    final esPendiente = recoleccion.estado == 'pendiente';
    final fecha = DateFormat("dd/MM/yyyy 'a las' HH:mm")
        .format(recoleccion.fechaHora);

    // Detectamos si hay alertas de calidad
    final tempAlta = recoleccion.temperatura > 10;
    final densBaja = recoleccion.densidad < 1.028;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Detalle del registro',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _filaDetalle(Icons.person, 'Productor', recoleccion.nombreProductor),
          _filaDetalle(Icons.opacity, 'Litros',
              '${recoleccion.litros.toStringAsFixed(2)} L'),
          _filaDetalle(Icons.access_time, 'Fecha', fecha),
          _filaDetalle(
            Icons.thermostat,
            'Temperatura',
            '${recoleccion.temperatura.toStringAsFixed(1)} °C',
            colorValor: tempAlta ? Colors.red : null,
          ),
          _filaDetalle(
            Icons.science,
            'Densidad',
            '${recoleccion.densidad.toStringAsFixed(3)} g/mL',
            colorValor: densBaja ? Colors.red : null,
          ),
          if (recoleccion.latitud != null && recoleccion.longitud != null)
            _filaDetalle(
              Icons.location_on,
              'GPS',
              '${recoleccion.latitud!.toStringAsFixed(4)}, '
                  '${recoleccion.longitud!.toStringAsFixed(4)}',
            ),
          _filaDetalle(Icons.route, 'Ruta', recoleccion.ruta),
          if (recoleccion.observaciones != null)
            _filaDetalle(Icons.notes, 'Observaciones',
                recoleccion.observaciones!),
          const Divider(height: 24),
          Row(
            children: [
              Icon(
                esPendiente ? Icons.cloud_off : Icons.cloud_done,
                color: esPendiente ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Estado: ${esPendiente ? "Pendiente" : "Sincronizado"}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: esPendiente ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          if (tempAlta || densBaja) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 20),
                      SizedBox(width: 6),
                      Text('Alertas de calidad',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (tempAlta)
                    const Text('• Temperatura por encima de 10°C'),
                  if (densBaja)
                    const Text('• Densidad baja (posible adulteración)'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // ID del registro (informativo)
          Text(
            'ID: ${recoleccion.id}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _filaDetalle(IconData icono, String etiqueta, String valor,
      {Color? colorValor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorValor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
