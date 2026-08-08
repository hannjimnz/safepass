import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/password.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('password_vault.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        servicio TEXT NOT NULL,
        usuario TEXT NOT NULL,
        password TEXT NOT NULL,
        clave TEXT NOT NULL,
        categoria TEXT NOT NULL,
        notas TEXT,
        icono TEXT,
        fechaCreacion TEXT NOT NULL
      )
    ''');
  }

  // INSERTAR
  Future<int> insertarPassword(Password password) async {
    final db = await database;

    return await db.insert(
      'passwords',
      password.toMap(),
    );
  }

  // OBTENER TODAS
  Future<List<Password>> obtenerPasswords() async {
    final db = await database;

    final result = await db.query(
      'passwords',
      orderBy: 'id DESC',
    );

    return result
        .map(
          (map) => Password.fromMap(map),
        )
        .toList();
  }

  // OBTENER UNA
  Future<Password?> obtenerPassword(int id) async {
    final db = await database;

    final result = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Password.fromMap(result.first);
    }

    return null;
  }

  // ACTUALIZAR
  Future<int> actualizarPassword(
    Password password,
  ) async {
    final db = await database;

    return await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  // ELIMINAR
  Future<int> eliminarPassword(int id) async {
    final db = await database;

    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CERRAR BASE DE DATOS
  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}