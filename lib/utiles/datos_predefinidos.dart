// Datos predefinidos del sistema.
// En un sistema real, estos vendrían del servidor.
// Para este prototipo los dejamos hardcodeados.

class DatosPredefinidos {
  // Lista de productores conocidos en la zona.
  // El acopiador elige uno de la lista al registrar la recolección.
  static const List<String> productores = [
    'José Quispe',
    'María Huamán',
    'Pedro Mamani',
    'Rosa Condori',
    'Luis Vargas',
    'Carmen Apaza',
    'Andrés Rojas',
    'Julia Flores',
  ];

  // Ruta del día (en un sistema real cambiaría por usuario y fecha)
  static const String rutaDelDia = 'Ruta Norte - Caserío San Juan';
}
