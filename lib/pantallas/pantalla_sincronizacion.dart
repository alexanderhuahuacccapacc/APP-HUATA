// Pantalla de sincronización SIMULADA.
// Toma todos los registros con estado "pendiente" y los marca como
// "sincronizado". En un sistema real, aquí se haría una petición HTTP
// al servidor; el UUID de cada registro evita duplicados.

import 'package:flutter/material.dart';

import '../servicios/base_datos.dart';
import '../servicios/servicio_sincronizacion.dart';

class PantallaSincronizacion extends StatefulWidget {
  const PantallaSincronizacion({super.key});

  @override
  State<PantallaSincronizacion> createState() => _PantallaSincronizacionState();
}

class _PantallaSincronizacionState extends State<PantallaSincronizacion> {
  int _pendientes = 0;
  bool _cargando = true;
  bool _sincronizando = false;
  int? _ultimoSincronizado;

  @override
  void initState() {
    super.initState();
    _contarPendientes();
  }

  Future<void> _contarPendientes() async {
    setState(() => _cargando = true);
    final cantidad = await BaseDatos.instancia.contarPendientes();
    if (!mounted) return;
    setState(() {
      _pendientes = cantidad;
      _cargando = false;
    });
  }

  // Ejecuta la sincronización simulada
  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
      _ultimoSincronizado = null;
    });

    final servicio = ServicioSincronizacion();
    final cantidad = await servicio.sincronizar();

    if (!mounted) return;
    setState(() {
      _sincronizando = false;
      _ultimoSincronizado = cantidad;
    });

    await _contarPendientes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cantidad == 0
              ? 'No había registros para sincronizar'
              : '✅ $cantidad registro(s) sincronizado(s)',
        ),
        backgroundColor: cantidad == 0 ? Colors.grey : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronización')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Icono ilustrativo grande
                  Icon(
                    _pendientes > 0 ? Icons.cloud_upload : Icons.cloud_done,
                    size: 100,
                    color: _pendientes > 0
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Estado actual
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _pendientes > 0
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _pendientes > 0 ? Colors.orange : Colors.green,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _pendientes > 0
                              ? 'REGISTROS PENDIENTES'
                              : 'TODO SINCRONIZADO',
                          style: TextStyle(
                            fontSize: 14,
                            color: _pendientes > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_pendientes',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _pendientes > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                        Text(
                          _pendientes == 1 ? 'registro' : 'registros',
                          style: TextStyle(
                            fontSize: 16,
                            color: _pendientes > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mensaje del último resultado
                  if (_ultimoSincronizado != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _ultimoSincronizado == 0
                                  ? 'Última sincronización: nada por enviar.'
                                  : 'Última sincronización: '
                                      '$_ultimoSincronizado registro(s) enviado(s).',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Botón sincronizar
                  ElevatedButton.icon(
                    onPressed: (_pendientes == 0 || _sincronizando)
                        ? null
                        : _sincronizar,
                    icon: _sincronizando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.sync, size: 28),
                    label: Text(
                      _sincronizando ? 'SINCRONIZANDO...' : 'SINCRONIZAR AHORA',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 6),
                            Text(
                              '¿Cómo funciona?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Los registros se guardan primero en su teléfono. '
                          'Cuando tenga internet, presione "Sincronizar" '
                          'para enviarlos al servidor.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
