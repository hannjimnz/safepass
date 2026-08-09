import 'package:flutter_test/flutter_test.dart';

import 'package:safepass/services/encryption_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'La contraseña se cifra y se descifra correctamente',
    () async {
      final encryptionService =
          EncryptionService();

      const textoOriginal =
          'Password123!';

      final textoCifrado =
          await encryptionService.encrypt(
        textoOriginal,
      );

      final textoDescifrado =
          await encryptionService.decrypt(
        textoCifrado,
      );

      expect(
        textoCifrado,
        isNot(textoOriginal),
      );

      expect(
        textoDescifrado,
        textoOriginal,
      );
    },
  );
}