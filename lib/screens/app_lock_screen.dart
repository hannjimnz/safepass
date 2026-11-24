import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_lock_provider.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLock = context.watch<AppLockProvider>();
    final message = appLock.message ??
        'Confirma tu identidad para volver a tu bóveda.';

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'SafePass está bloqueado',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                if (appLock.isAuthenticating)
                  const CircularProgressIndicator()
                else
                  FilledButton.icon(
                    onPressed: appLock.autenticarParaDesbloquear,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Desbloquear'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
