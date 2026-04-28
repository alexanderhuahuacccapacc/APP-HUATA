// Servicio que maneja la base de datos local SQLite.
// Aquí se crean las tablas y se hacen las operaciones CRUD
// (insertar, leer, actualizar) sobre las recolecciones.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../modelos/recoleccion.dart';

class BaseDatos {
  // Patrón Singleton: una sola instancia de base de datos en toda la app
  static final BaseDatos instancia = BaseDatos._interno();
  BaseDatos._interno();

  static Database? _bd;

  // Devuelve la base de datos. Si no existe aún, la crea.
  Future<Database> get baseDatos async {
    if (_bd != null) return _bd!;
    _bd = await _inicializar();
    return _bd!;
  }

  // Crea o abre el archivo SQLite y la tabla de recolecciones
  Future<Database> _inicializar() async {
    final rutaBd = await getDatabasesPath();
    final ruta = join(rutaBd, 'recojo_leche.db');

    return await openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recolecciones (
            id TEXT PRIMARY KEY,
            nombreProductor TEXT NOT NULL,
            litros REAL NOT NULL,
            fechaHora TEXT NOT NULL,
            latitud REAL,
            longitud REAL,
            temperatura REAL NOT NULL,
            densidad REAL NOT NULL,
            observaciones TEXT,
            estado TEXT NOT NULL,
            ruta TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Inserta una nueva recolección en la BD local
  Future<void> insertarRecoleccion(Recoleccion recoleccion) async {
    final db = await baseDatos;
    await db.insert(
      'recolecciones',
      recoleccion.aMapa(),
      // Si por alguna razón el UUID ya existe, lo reemplaza.
      // Esto previene duplicados.
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Devuelve TODAS las recolecciones, ordenadas de la más reciente a la más antigua
  Future<List<Recoleccion>> obtenerTodas() async {
    final db = await baseDatos;
    final List<Map<String, dynamic>> resultado = await db.query(
      'recolecciones',
      orderBy: 'fechaHora DESC',
    );
    return resultado.map((m) => Recoleccion.desdeMapa(m)).toList();
  }

  // Devuelve solo las que están pendientes de sincronizar
  Future<List<Recoleccion>> obtenerPendientes() async {
    final db = await baseDatos;
    final resultado = await db.query(
      'recolecciones',
      where: 'estado = ?',
      whereArgs: ['pendiente'],
    );
    return resultado.map((m) => Recoleccion.desdeMapa(m)).toList();
  }

  // Marca una recolección como "sincronizada"
  Future<void> marcarComoSincronizada(String id) async {
    final db = await baseDatos;
    await db.update(
      'recolecciones',
      {'estado': 'sincronizado'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cuenta cuántas hay pendientes (útil para mostrar badges)
  Future<int> contarPendientes() async {
    final db = await baseDatos;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM recolecciones WHERE estado = ?',
      ['pendiente'],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
