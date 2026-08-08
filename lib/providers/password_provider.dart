import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/password.dart';

class PasswordProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Password> _passwords = [];

  List<Password> get passwords => _passwords;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Cargar contraseñas
  Future<void> cargarPasswords() async {
    _isLoading = true;

    notifyListeners();

    _passwords = await _databaseHelper.obtenerPasswords();

    _isLoading = false;

    notifyListeners();
  }

  // Agregar
  Future<void> agregarPassword(
    Password password,
  ) async {
    await _databaseHelper.insertarPassword(password);

    await cargarPasswords();
  }

  // Actualizar
  Future<void> actualizarPassword(
    Password password,
  ) async {
    await _databaseHelper.actualizarPassword(password);

    await cargarPasswords();
  }

  // Eliminar
  Future<void> eliminarPassword(int id) async {
    await _databaseHelper.eliminarPassword(id);

    await cargarPasswords();
  }

  // Buscar
  List<Password> buscarPasswords(String texto) {
    if (texto.isEmpty) {
      return _passwords;
    }

    final textoLower = texto.toLowerCase();

    return _passwords.where((password) {
      return password.servicio
              .toLowerCase()
              .contains(textoLower) ||
          password.usuario
              .toLowerCase()
              .contains(textoLower) ||
          password.categoria
              .toLowerCase()
              .contains(textoLower);
    }).toList();
  }
}