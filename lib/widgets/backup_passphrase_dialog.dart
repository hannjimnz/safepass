import 'package:flutter/material.dart';

class BackupPassphraseDialog extends StatefulWidget {
  final bool confirmPassphrase;

  const BackupPassphraseDialog({
    super.key,
    required this.confirmPassphrase,
  });

  @override
  State<BackupPassphraseDialog> createState() =>
      _BackupPassphraseDialogState();
}

class _BackupPassphraseDialogState extends State<BackupPassphraseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passphraseController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _showPassphrase = false;

  @override
  void dispose() {
    _passphraseController.clear();
    _confirmationController.clear();
    _passphraseController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.pop(context, _passphraseController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isExport = widget.confirmPassphrase;

    return AlertDialog(
      title: Text(isExport ? 'Proteger respaldo' : 'Abrir respaldo'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExport
                  ? 'Crea una frase de al menos 16 caracteres. La necesitarás para restaurar el respaldo; SafePass no puede recuperarla.'
                  : 'Escribe la frase que usaste al crear este respaldo.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passphraseController,
              autofocus: true,
              obscureText: !_showPassphrase,
              decoration: InputDecoration(
                labelText: 'Frase de respaldo',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: _showPassphrase ? 'Ocultar frase' : 'Mostrar frase',
                  onPressed: () {
                    setState(() {
                      _showPassphrase = !_showPassphrase;
                    });
                  },
                  icon: Icon(
                    _showPassphrase
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 16) {
                  return 'Usa al menos 16 caracteres';
                }
                return null;
              },
            ),
            if (isExport) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmationController,
                obscureText: !_showPassphrase,
                decoration: const InputDecoration(
                  labelText: 'Confirma la frase',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _passphraseController.text) {
                    return 'Las frases no coinciden';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _continue(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _continue,
          child: Text(isExport ? 'Crear respaldo' : 'Continuar'),
        ),
      ],
    );
  }
}
