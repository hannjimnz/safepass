import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth =
      LocalAuthentication();

  // ============================================================
  // COMPROBAR SI EL DISPOSITIVO ADMITE AUTENTICACIÓN LOCAL
  // ============================================================

  Future<bool> puedeAutenticar() async {
    try {
      // isDeviceSupported también contempla el PIN, patrón o código
      // del dispositivo cuando no hay biometría disponible.
      return await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // OBTENER BIOMETRÍAS DISPONIBLES
  // ============================================================

  Future<List<BiometricType>>
      obtenerBiometriasDisponibles() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // AUTENTICAR
  // ============================================================

  Future<bool> autenticar() async {
    try {
      final disponible =
          await puedeAutenticar();

      if (!disponible) {
        return false;
      }

      final autenticado =
          await _auth.authenticate(
        localizedReason:
            'Autentícate para acceder a tus contraseñas',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      return autenticado;
    } catch (e) {
      return false;
    }
  }
}
