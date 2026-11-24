import 'package:flutter/widgets.dart';

import '../services/biometric_service.dart';

class AppLockProvider extends ChangeNotifier with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();

  bool _hasAuthenticated = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  String? _message;

  bool get isLocked => _isLocked;
  bool get isAuthenticating => _isAuthenticating;
  String? get message => _message;

  AppLockProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  void markAuthenticated() {
    _hasAuthenticated = true;
    _isLocked = false;
    _isAuthenticating = false;
    _message = null;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasAuthenticated) return;

    if (state == AppLifecycleState.paused && !_isLocked) {
      _isLocked = true;
      _message = null;
      notifyListeners();
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _isLocked &&
        !_isAuthenticating) {
      autenticarParaDesbloquear();
    }
  }

  Future<void> autenticarParaDesbloquear() async {
    if (!_isLocked || _isAuthenticating) return;

    _isAuthenticating = true;
    _message = null;
    notifyListeners();

    final disponible = await _biometricService.puedeAutenticar();
    final autenticado = disponible &&
        await _biometricService.autenticar();

    _isAuthenticating = false;

    if (autenticado) {
      _isLocked = false;
      _message = null;
    } else if (!disponible) {
      _message =
          'Configura un PIN, patrón o contraseña de bloqueo en tu dispositivo para proteger SafePass.';
    } else {
      _message = 'No se completó la autenticación. Inténtalo de nuevo.';
    }

    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
