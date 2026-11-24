import 'dart:math';

class PasswordGeneratorService {
  final Random _random = Random.secure();

  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  String generate({
    required int length,
    required bool includeLowercase,
    required bool includeUppercase,
    required bool includeDigits,
    required bool includeSymbols,
  }) {
    final characterGroups = <String>[
      if (includeLowercase) _lowercase,
      if (includeUppercase) _uppercase,
      if (includeDigits) _digits,
      if (includeSymbols) _symbols,
    ];

    if (characterGroups.isEmpty) {
      throw ArgumentError('Selecciona al menos un tipo de carácter.');
    }

    if (length < characterGroups.length) {
      throw ArgumentError(
        'La longitud debe permitir incluir todos los tipos seleccionados.',
      );
    }

    final allCharacters = characterGroups.join();
    final characters = <String>[
      for (final group in characterGroups)
        group[_random.nextInt(group.length)],
    ];

    while (characters.length < length) {
      characters.add(
        allCharacters[_random.nextInt(allCharacters.length)],
      );
    }

    for (var index = characters.length - 1; index > 0; index--) {
      final swapIndex = _random.nextInt(index + 1);
      final current = characters[index];
      characters[index] = characters[swapIndex];
      characters[swapIndex] = current;
    }

    return characters.join();
  }
}
