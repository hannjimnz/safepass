import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const String _keyStorageName =
      'password_vault_encryption_key';

  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  Future<Key> _obtenerClave() async {
    String? keyString =
        await _secureStorage.read(
      key: _keyStorageName,
    );

    if (keyString == null) {
      final key = Key.fromSecureRandom(32);

      keyString = key.base64;

      await _secureStorage.write(
        key: _keyStorageName,
        value: keyString,
      );

      return key;
    }

    return Key.fromBase64(keyString);
  }

  Future<String> encrypt(String texto) async {
    if (texto.isEmpty) {
      return '';
    }
    final key = await _obtenerClave();

    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(
      AES(key),
    );

    final encrypted = encrypter.encrypt(
      texto,
      iv: iv,
    );

    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decrypt(String textoCifrado) async {
    if (textoCifrado.isEmpty) {
      return '';
    }

    final key = await _obtenerClave();

    final partes = textoCifrado.split(':');

    if (partes.length != 2) {
      throw Exception(
        'Texto cifrado inválido.',
      );
    }

    final iv = IV.fromBase64(
      partes[0],
    );

    final encrypted = Encrypted.fromBase64(
      partes[1],
    );

    final encrypter = Encrypter(
      AES(key),
    );

    return encrypter.decrypt(
      encrypted,
      iv: iv,
    );
  }
}
