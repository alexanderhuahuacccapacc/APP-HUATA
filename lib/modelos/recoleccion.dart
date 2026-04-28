// Modelo que representa una recolección de leche.
// Esta clase se usa tanto en la base de datos local (SQLite)
// como en las pantallas de la app.

class Recoleccion {
  // Identificador único universal (UUID).
  // Sirve para evitar duplicados al sincronizar.
  final String id;

  final String nombreProductor;
  final double litros;
  final DateTime fechaHora;

  // Coordenadas GPS opcionales (simuladas en este prototipo)
  final double? latitud;
  final double? longitud;

  final double temperatura; // en °C
  final double densidad;    // en g/mL
  final String? observaciones;

  // Estado del registro:
  // "pendiente"     -> aún no sincronizado con el servidor
  // "sincronizado"  -> ya fue enviado al servidor (simulado)
  final String estado;

  // Ruta del día asociada al registro (texto fijo en este prototipo)
  final String ruta;

  Recoleccion({
    required this.id,
    required this.nombreProductor,
    required this.litros,
    required this.fechaHora,
    this.latitud,
    this.longitud,
    required this.temperatura,
    required this.densidad,
    this.observaciones,
    required this.estado,
    required this.ruta,
  });

  // Convierte el objeto en un Map para guardarlo en SQLite
  Map<String, dynamic> aMapa() {
    return {
      'id': id,
      'nombreProductor': nombreProductor,
      'litros': litros,
      'fechaHora': fechaHora.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'temperatura': temperatura,
      'densidad': densidad,
      'observaciones': observaciones,
      'estado': estado,
      'ruta': ruta,
    };
  }

  // Reconstruye un objeto Recoleccion desde un Map de SQLite
  factory Recoleccion.desdeMapa(Map<String, dynamic> mapa) {
    return Recoleccion(
      id: mapa['id'] as String,
      nombreProductor: mapa['nombreProductor'] as String,
      litros: (mapa['litros'] as num).toDouble(),
      fechaHora: DateTime.parse(mapa['fechaHora'] as String),
      latitud: mapa['latitud'] != null
          ? (mapa['latitud'] as num).toDouble()
          : null,
      longitud: mapa['longitud'] != null
          ? (mapa['longitud'] as num).toDouble()
          : null,
      temperatura: (mapa['temperatura'] as num).toDouble(),
      densidad: (mapa['densidad'] as num).toDouble(),
      observaciones: mapa['observaciones'] as String?,
      estado: mapa['estado'] as String,
      ruta: mapa['ruta'] as String,
    );
  }

  // Crea una copia del registro con algunos campos modificados.
  // Útil para cambiar el estado al sincronizar.
  Recoleccion copiarCon({String? estado}) {
    return Recoleccion(
      id: id,
      nombreProductor: nombreProductor,
      litros: litros,
      fechaHora: fechaHora,
      latitud: latitud,
      longitud: longitud,
      temperatura: temperatura,
      densidad: densidad,
      observaciones: observaciones,
      estado: estado ?? this.estado,
      ruta: ruta,
    );
  }
}
