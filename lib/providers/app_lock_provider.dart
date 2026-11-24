import 'package:flutter/widgets.dart';

import '../services/biometric_service.dart';

class AppLockProvider extends ChangeNotifier with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();

  bool _hasAuthenticated = false;
  bool _isLocked = false;
  bool _isAuthenticating = false;
  String? _message;
  int _externalActivityDepth = 0;
  bool _pausedForExternalActivity = false;

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

    if (_externalActivityDepth > 0) {
      if (state == AppLifecycleState.paused) {
        _pausedForExternalActivity = true;
      }
      return;
    }

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

  Future<bool> autenticarParaDesbloquear() async {
    if (!_isLocked || _isAuthenticating) return !_isLocked;

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
    return autenticado;
  }

  Future<T> runWithSystemFilePicker<T>(
    Future<T> Function() operation,
  ) async {
    _externalActivityDepth++;
    try {
      return await operation();
    } finally {
      _externalActivityDepth--;
      if (_externalActivityDepth == 0 &&
          _pausedForExternalActivity &&
          _hasAuthenticated) {
        _pausedForExternalActivity = false;
        _isLocked = true;
        _message = null;
        notifyListeners();
        await autenticarParaDesbloquear();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
