import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/password.dart';
import '../services/encryption_service.dart';

class PasswordProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper =
      DatabaseHelper.instance;

  final EncryptionService _encryptionService =
      EncryptionService();

  List<Password> _passwords = [];

  List<Password> get passwords => _passwords;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // ============================================================
  // CARGAR CONTRASEÑAS
  // ============================================================

  Future<void> cargarPasswords() async {
    _isLoading = true;

    notifyListeners();

    try {
      debugPrint(
        '========== CARGANDO CONTRASEÑAS ==========',
      );

      // Obtener contraseñas cifradas desde SQLite
      final passwordsCifradas =
          await _databaseHelper.obtenerPasswords();

      debugPrint(
        'Registros encontrados en SQLite: '
        '${passwordsCifradas.length}',
      );

      final passwordsDescifradas = <Password>[];

      // Descifrar cada registro
      for (final password in passwordsCifradas) {
        debugPrint(
          'Descifrando registro ID: ${password.id}',
        );

        // Descifrar contraseña
        final passwordDescifrada =
            await _encryptionService.decrypt(
          password.password,
        );

        final servicioDescifrado =
            await _encryptionService.decrypt(
          password.servicio,
        );

        final usuarioDescifrado =
            await _encryptionService.decrypt(
          password.usuario,
        );

        // Si la clave está vacía, no intentamos descifrarla
        final claveDescifrada =
            await _encryptionService.decrypt(
          password.clave,
        );

        final notasDescifradas =
            await _encryptionService.decrypt(
          password.notas,
        );

        passwordsDescifradas.add(
          Password(
            id: password.id,
            servicio: servicioDescifrado,
            usuario: usuarioDescifrado,
            password: passwordDescifrada,
            clave: claveDescifrada,
            categoria: password.categoria,
            notas: notasDescifradas,
            icono: password.icono,
            fechaCreacion: password.fechaCreacion,
          ),
        );
      }

      _passwords = passwordsDescifradas;

      debugPrint(
        'Contraseñas cargadas correctamente: '
        '${_passwords.length}',
      );

      debugPrint(
        '===========================================',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ ERROR AL CARGAR CONTRASEÑAS',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      _passwords = [];
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // AGREGAR CONTRASEÑA
  // ============================================================

  Future<void> agregarPassword(
    Password password,
  ) async {
    try {
      debugPrint(
        '========== AGREGANDO CONTRASEÑA ==========',
      );

      // --------------------------------------------------------
      // CIFRAR CONTRASEÑA
      // --------------------------------------------------------

      final passwordCifrada =
          await _encryptionService.encrypt(
        password.password,
      );

      final servicioCifrado =
          await _encryptionService.encrypt(
        password.servicio,
      );

      final usuarioCifrado =
          await _encryptionService.encrypt(
        password.usuario,
      );

      final notasCifradas =
          await _encryptionService.encrypt(
        password.notas,
      );

      debugPrint(
        '✅ Contraseña cifrada correctamente',
      );

      // --------------------------------------------------------
      // CIFRAR CLAVE
      // --------------------------------------------------------

      // Si la clave está vacía, guardamos ''
      final claveCifrada =
          await _encryptionService.encrypt(
        password.clave,
      );

      debugPrint(
        '✅ Clave procesada correctamente',
      );

      // --------------------------------------------------------
      // CREAR OBJETO PARA SQLITE
      // --------------------------------------------------------

      final passwordParaGuardar = Password(
        id: password.id,
        servicio: servicioCifrado,
        usuario: usuarioCifrado,
        password: passwordCifrada,
        clave: claveCifrada,
        categoria: password.categoria,
        notas: notasCifradas,
        icono: password.icono,
        fechaCreacion: password.fechaCreacion,
      );

      debugPrint(
        'Guardando contraseña en SQLite...',
      );

      // --------------------------------------------------------
      // GUARDAR EN SQLITE
      // --------------------------------------------------------

      final id =
          await _databaseHelper.insertarPassword(
        passwordParaGuardar,
      );

      debugPrint(
        '✅ Contraseña guardada en SQLite',
      );

      debugPrint(
        'ID generado: $id',
      );

      // --------------------------------------------------------
      // RECARGAR LISTA
      // --------------------------------------------------------

      await cargarPasswords();

      debugPrint(
        '✅ Lista recargada',
      );

      debugPrint(
        'Cantidad actual: ${_passwords.length}',
      );

      debugPrint(
        '===========================================',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ ERROR AL AGREGAR CONTRASEÑA',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      rethrow;
    }
  }

  // ============================================================
  // ACTUALIZAR CONTRASEÑA
  // ============================================================

  Future<void> actualizarPassword(
    Password password,
  ) async {
    try {
      // Cifrar nuevamente la contraseña
      final passwordCifrada =
          await _encryptionService.encrypt(
        password.password,
      );

      final servicioCifrado =
          await _encryptionService.encrypt(
        password.servicio,
      );

      final usuarioCifrado =
          await _encryptionService.encrypt(
        password.usuario,
      );

      final notasCifradas =
          await _encryptionService.encrypt(
        password.notas,
      );

      // Si la clave está vacía, guardamos ''
      final claveCifrada =
          await _encryptionService.encrypt(
        password.clave,
      );

      // Crear objeto con datos cifrados
      final passwordParaGuardar = Password(
        id: password.id,
        servicio: servicioCifrado,
        usuario: usuarioCifrado,
        password: passwordCifrada,
        clave: claveCifrada,
        categoria: password.categoria,
        notas: notasCifradas,
        icono: password.icono,
        fechaCreacion: password.fechaCreacion,
      );

      // Actualizar SQLite
      await _databaseHelper.actualizarPassword(
        passwordParaGuardar,
      );

      // Recargar lista
      await cargarPasswords();
    } catch (e, stackTrace) {
      debugPrint(
        '❌ ERROR AL ACTUALIZAR CONTRASEÑA',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      rethrow;
    }
  }

  // ============================================================
  // ELIMINAR CONTRASEÑA
  // ============================================================

  Future<void> eliminarPassword(
    int id,
  ) async {
    try {
      await _databaseHelper.eliminarPassword(id);

      await cargarPasswords();
    } catch (e, stackTrace) {
      debugPrint(
        '❌ ERROR AL ELIMINAR CONTRASEÑA',
      );

      debugPrint(
        e.toString(),
      );

      debugPrint(
        stackTrace.toString(),
      );

      rethrow;
    }
  }

  // ============================================================
  // BUSCAR CONTRASEÑAS
  // ============================================================

  List<Password> buscarPasswords(
    String texto,
  ) {
    if (texto.isEmpty) {
      return _passwords;
    }

    final textoLower =
        texto.toLowerCase();

    return _passwords.where(
      (password) {
        return password.servicio
                .toLowerCase()
                .contains(textoLower) ||
            password.usuario
                .toLowerCase()
                .contains(textoLower) ||
            password.categoria
                .toLowerCase()
                .contains(textoLower);
      },
    ).toList();
  }
}
