import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth =
      LocalAuthentication();

  // ============================================================
  // COMPROBAR SI EL DISPOSITIVO SOPORTA BIOMETRÍA
  // ============================================================

  Future<bool> puedeAutenticar() async {
    try {
      final disponible =
          await _auth.isDeviceSupported();

      final tieneBiometria =
          await _auth.canCheckBiometrics;

      return disponible && tieneBiometria;
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
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      return autenticado;
    } catch (e) {
      return false;
    }
  }
}