import 'package:flutter/material.dart';

import '../services/password_generator_service.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  final PasswordGeneratorService _generator = PasswordGeneratorService();

  int _length = 16;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeDigits = true;
  bool _includeSymbols = true;
  late String _generatedPassword;

  bool get _hasCharacterType =>
      _includeLowercase ||
      _includeUppercase ||
      _includeDigits ||
      _includeSymbols;

  @override
  void initState() {
    super.initState();
    _generatedPassword = _generatePassword();
  }

  String _generatePassword() {
    if (!_hasCharacterType) return '';

    return _generator.generate(
      length: _length,
      includeLowercase: _includeLowercase,
      includeUppercase: _includeUppercase,
      includeDigits: _includeDigits,
      includeSymbols: _includeSymbols,
    );
  }

  void _updateOptions(VoidCallback update) {
    setState(() {
      update();
      _generatedPassword = _generatePassword();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generar contraseña'),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Longitud: $_length'),
          Slider(
            value: _length.toDouble(),
            min: 8,
            max: 64,
            divisions: 56,
            label: '$_length',
            onChanged: (value) {
              setState(() {
                _length = value.round();
                _generatedPassword = _generatePassword();
              });
            },
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Minúsculas (a-z)'),
            value: _includeLowercase,
            onChanged: (value) => _updateOptions(
              () => _includeLowercase = value ?? false,
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mayúsculas (A-Z)'),
            value: _includeUppercase,
            onChanged: (value) => _updateOptions(
              () => _includeUppercase = value ?? false,
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Números (0-9)'),
            value: _includeDigits,
            onChanged: (value) => _updateOptions(
              () => _includeDigits = value ?? false,
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Símbolos (!@#...)'),
            value: _includeSymbols,
            onChanged: (value) => _updateOptions(
              () => _includeSymbols = value ?? false,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _generatedPassword.isEmpty
                        ? 'Selecciona al menos un tipo de carácter'
                        : _generatedPassword,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  tooltip: 'Generar otra',
                  onPressed: _hasCharacterType
                      ? () => setState(() {
                            _generatedPassword = _generatePassword();
                          })
                      : null,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _hasCharacterType
              ? () => Navigator.pop(context, _generatedPassword)
              : null,
          child: const Text('Usar contraseña'),
        ),
      ],
    );
  }
}
