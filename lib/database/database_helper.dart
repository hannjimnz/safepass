import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/password.dart';
import '../services/encryption_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB(
      'password_vault.db',
    );

    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      filePath,
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      final rows = await db.query(
        'passwords',
        columns: ['id', 'servicio', 'usuario', 'notas'],
      );
      final encryptionService = EncryptionService();
      final batch = db.batch();

      for (final row in rows) {
        batch.update(
          'passwords',
          {
            'servicio': await encryptionService.encrypt(
              row['servicio'] as String,
            ),
            'usuario': await encryptionService.encrypt(
              row['usuario'] as String,
            ),
            'notas': await encryptionService.encrypt(
              (row['notas'] as String?) ?? '',
            ),
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }

      await batch.commit(noResult: true);
    }
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
  Future<int> insertarPassword(
    Password password,
  ) async {
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
  Future<Password?> obtenerPassword(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Password.fromMap(
        result.first,
      );
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
  Future<int> eliminarPassword(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reemplazarPasswords(
    List<Password> passwords,
  ) async {
    final db = await database;

    await db.transaction((transaction) async {
      await transaction.delete('passwords');

      final batch = transaction.batch();
      for (final password in passwords) {
        batch.insert('passwords', password.toMap());
      }

      await batch.commit(noResult: true);
    });
  }

  // CERRAR BASE DE DATOS
  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}
