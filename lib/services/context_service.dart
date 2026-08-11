class ContextService {
  // ============================================================
  // DETERMINAR SI ES MODO NOCTURNO
  // ============================================================

  bool esModoNocturno() {
    final ahora = DateTime.now();

    final hora = ahora.hour;

    // Día: 06:00 - 18:59
    // Noche: 19:00 - 05:59

    return hora >= 19 || hora < 6;
  }

  // ============================================================
  // DETERMINAR SI ES MODO DIURNO
  // ============================================================

  bool esModoDiurno() {
    return !esModoNocturno();
  }

  // ============================================================
  // OBTENER SALUDO
  // ============================================================

  String obtenerSaludo() {
    final ahora = DateTime.now();

    final hora = ahora.hour;

    if (hora < 6) {
      return 'Buenas noches';
    }

    if (hora < 12) {
      return 'Buenos días';
    }

    if (hora < 19) {
      return 'Buenas tardes';
    }

    return 'Buenas noches';
  }

  // ============================================================
  // OBTENER MENSAJE DEL CONTEXTO
  // ============================================================

  String obtenerMensajeContexto() {
    if (esModoNocturno()) {
      return 'Modo nocturno activado';
    }

    return 'Tu bóveda está protegida';
  }
}