import 'dart:async';

import 'package:flutter/material.dart';

import '../services/context_service.dart';

class ContextProvider extends ChangeNotifier {
  final ContextService _contextService =
      ContextService();

  bool _esModoNocturno = false;

  String _saludo = '';

  String _mensaje = '';

  Timer? _timer;

  bool get esModoNocturno => _esModoNocturno;

  String get saludo => _saludo;

  String get mensaje => _mensaje;

  // ============================================================
  // INICIALIZAR CONTEXTO
  // ============================================================

  void inicializarContexto() {
    actualizarContexto();

    // Revisar la hora cada minuto
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        actualizarContexto();
      },
    );
  }

  // ============================================================
  // ACTUALIZAR CONTEXTO
  // ============================================================

  void actualizarContexto() {
    final nuevoModoNocturno =
        _contextService.esModoNocturno();

    final nuevoSaludo =
        _contextService.obtenerSaludo();

    final nuevoMensaje =
        _contextService.obtenerMensajeContexto();

    // Solo notificamos si realmente cambió algo
    if (_esModoNocturno != nuevoModoNocturno ||
        _saludo != nuevoSaludo ||
        _mensaje != nuevoMensaje) {
      _esModoNocturno = nuevoModoNocturno;

      _saludo = nuevoSaludo;

      _mensaje = nuevoMensaje;

      notifyListeners();
    }
  }

  // ============================================================
  // LIBERAR RECURSOS
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }
}