import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart' as pointycastle;

import '../models/password.dart';

class BackupService {
  static const int maxBackupSizeBytes = 25 * 1024 * 1024;
  static const int _formatVersion = 1;
  static const int _kdfIterations = 600000;
  static const int _keyLengthBytes = 32;
  static const String _formatName = 'safepass-backup';
  static const String _kdfName = 'PBKDF2-HMAC-SHA256';
  static const String _cipherName = 'AES-256-GCM';
  static const List<int> _associatedData = <int>[
    83,
    97,
    102,
    101,
    80,
    97,
    115,
    115,
    32,
    98,
    97,
    99,
    107,
    117,
    112,
    32,
    118,
    49,
  ];

  final Random _secureRandom = Random.secure();

  Future<Uint8List> crearRespaldo(
    List<Password> passwords,
    String frase,
  ) async {
    _validarFrase(frase);
    if (passwords.length > 10000) {
      throw const FormatException('La bóveda tiene demasiados registros.');
    }

    final payload = utf8.encode(
      jsonEncode({
        'version': _formatVersion,
        'entradas': passwords.map(_passwordToJson).toList(),
      }),
    );

    final salt = _randomBytes(16);
    final iv = _randomBytes(12);
    final keyBytes = await _deriveKey(frase, salt);

    try {
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(keyBytes),
          mode: encrypt.AESMode.gcm,
        ),
      );
      final encrypted = encrypter.encryptBytes(
        payload,
        iv: encrypt.IV(iv),
        associatedData: Uint8List.fromList(_associatedData),
      );

      final envelope = utf8.encode(
        jsonEncode({
          'formato': _formatName,
          'version': _formatVersion,
          'kdf': _kdfName,
          'iteraciones': _kdfIterations,
          'cifrado': _cipherName,
          'salt': base64Encode(salt),
          'iv': base64Encode(iv),
          'datos': encrypted.base64,
        }),
      );

      if (envelope.length > maxBackupSizeBytes) {
        throw const FormatException(
          'El respaldo supera el tamaño máximo permitido.',
        );
      }

      return Uint8List.fromList(envelope);
    } finally {
      keyBytes.fillRange(0, keyBytes.length, 0);
      payload.fillRange(0, payload.length, 0);
    }
  }

  Future<List<Password>> abrirRespaldo(
    Uint8List bytes,
    String frase,
  ) async {
    _validarFrase(frase);
    if (bytes.isEmpty || bytes.length > maxBackupSizeBytes) {
      throw const FormatException('El archivo de respaldo no es válido.');
    }

    final Object? decodedEnvelope;
    try {
      decodedEnvelope = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const FormatException('El archivo de respaldo está dañado.');
    }

    if (decodedEnvelope is! Map<String, dynamic>) {
      throw const FormatException('El archivo no es un respaldo de SafePass.');
    }

    final envelope = decodedEnvelope;
    if (envelope['formato'] != _formatName ||
        envelope['version'] != _formatVersion ||
        envelope['kdf'] != _kdfName ||
        envelope['iteraciones'] != _kdfIterations ||
        envelope['cifrado'] != _cipherName) {
      throw const FormatException(
        'El formato del respaldo no es compatible.',
      );
    }

    final salt = _decodeBase64(envelope['salt'], expectedLength: 16);
    final iv = _decodeBase64(envelope['iv'], expectedLength: 12);
    final ciphertext = _decodeBase64(envelope['datos']);
    final keyBytes = await _deriveKey(frase, salt);

    try {
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(keyBytes),
          mode: encrypt.AESMode.gcm,
        ),
      );

      final plaintext = encrypter.decryptBytes(
        encrypt.Encrypted(ciphertext),
        iv: encrypt.IV(iv),
        associatedData: Uint8List.fromList(_associatedData),
      );

      try {
        return _parseEntries(utf8.decode(plaintext));
      } finally {
        plaintext.fillRange(0, plaintext.length, 0);
      }
    } catch (_) {
      throw const FormatException(
        'No se pudo abrir el respaldo. Revisa la frase o el archivo.',
      );
    } finally {
      keyBytes.fillRange(0, keyBytes.length, 0);
    }
  }

  void _validarFrase(String frase) {
    if (frase.trim().length < 16) {
      throw const FormatException(
        'Usa una frase de respaldo de al menos 16 caracteres.',
      );
    }
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(
        length,
        (_) => _secureRandom.nextInt(256),
      ),
    );
  }

  Future<Uint8List> _deriveKey(String frase, Uint8List salt) {
    return compute(
      _deriveBackupKey,
      <String, Object>{'frase': frase, 'salt': salt},
    );
  }

  List<Password> _parseEntries(String json) {
    final Object? decodedPayload;
    try {
      decodedPayload = jsonDecode(json);
    } on FormatException {
      throw const FormatException('El contenido del respaldo está dañado.');
    }

    if (decodedPayload is! Map<String, dynamic> ||
        decodedPayload['version'] != _formatVersion ||
        decodedPayload['entradas'] is! List) {
      throw const FormatException('El contenido del respaldo no es válido.');
    }

    final entries = decodedPayload['entradas'] as List<dynamic>;
    if (entries.length > 10000) {
      throw const FormatException('El respaldo tiene demasiados registros.');
    }

    return entries.map((entry) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Un registro del respaldo no es válido.');
      }

      final fecha = DateTime.tryParse(_requiredString(entry, 'fechaCreacion'));
      if (fecha == null) {
        throw const FormatException('Una fecha del respaldo no es válida.');
      }

      final icon = entry['icono'];
      if (icon != null && icon is! String) {
        throw const FormatException('Un icono del respaldo no es válido.');
      }

      return Password(
        servicio: _requiredString(entry, 'servicio'),
        usuario: _requiredString(entry, 'usuario'),
        password: _requiredString(entry, 'password'),
        clave: _requiredString(entry, 'clave'),
        categoria: _requiredString(entry, 'categoria'),
        notas: _requiredString(entry, 'notas'),
        icono: icon as String?,
        fechaCreacion: fecha,
      );
    }).toList();
  }

  String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException('El campo $key del respaldo no es válido.');
    }
    return value;
  }

  Uint8List _decodeBase64(Object? value, {int? expectedLength}) {
    if (value is! String) {
      throw const FormatException('El archivo de respaldo está dañado.');
    }

    try {
      final decoded = base64Decode(value);
      if (expectedLength != null && decoded.length != expectedLength) {
        throw const FormatException('El archivo de respaldo está dañado.');
      }
      return decoded;
    } on FormatException {
      throw const FormatException('El archivo de respaldo está dañado.');
    }
  }

  Map<String, dynamic> _passwordToJson(Password password) {
    return {
      'servicio': password.servicio,
      'usuario': password.usuario,
      'password': password.password,
      'clave': password.clave,
      'categoria': password.categoria,
      'notas': password.notas,
      'icono': password.icono,
      'fechaCreacion': password.fechaCreacion.toIso8601String(),
    };
  }
}

Uint8List _deriveBackupKey(Map<String, Object> parameters) {
  final frase = parameters['frase'] as String;
  final salt = parameters['salt'] as Uint8List;
  final derivator = pointycastle.PBKDF2KeyDerivator(
    pointycastle.HMac(pointycastle.SHA256Digest(), 64),
  )..init(
      pointycastle.Pbkdf2Parameters(
        salt,
        BackupService._kdfIterations,
        BackupService._keyLengthBytes,
      ),
    );

  final phraseBytes = Uint8List.fromList(utf8.encode(frase));
  try {
    return derivator.process(phraseBytes);
  } finally {
    phraseBytes.fillRange(0, phraseBytes.length, 0);
  }
}
