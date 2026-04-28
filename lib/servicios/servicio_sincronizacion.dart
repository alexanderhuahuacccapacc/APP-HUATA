// Servicio que SIMULA la sincronización con un servidor remoto.
// En este prototipo NO hay backend real: simplemente cambiamos
// el estado de los registros pendientes a "sincronizado".
//
// En un sistema real, aquí se haría una petición HTTP al servidor,
// y solo después de recibir confirmación se marcaría como sincronizado.

import 'base_datos.dart';

class ServicioSincronizacion {
  final BaseDatos _bd = BaseDatos.instancia;

  // Simula el envío al servidor.
  // Devuelve la cantidad de registros sincronizados.
  Future<int> sincronizar() async {
    // 1. Obtenemos los registros que aún están pendientes
    final pendientes = await _bd.obtenerPendientes();

    if (pendientes.isEmpty) return 0;

    // 2. Simulamos el delay de red (como si estuviéramos enviando datos)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Marcamos cada uno como "sincronizado".
    //    El UUID de cada registro evita que se duplique en el servidor:
    //    si ya existe ese ID, el servidor real lo ignoraría.
    int contador = 0;
    for (final recoleccion in pendientes) {
      await _bd.marcarComoSincronizada(recoleccion.id);
      contador++;
    }

    return contador;
  }
}
