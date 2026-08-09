import 'dart:async';

import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BiometricService _biometricService =
      BiometricService();

  bool _autenticando = false;
  String _mensaje = 'Iniciando SafePass...';

  @override
  void initState() {
    super.initState();

    _iniciar();
  }

  Future<void> _iniciar() async {
    // Mostrar el Splash durante 2 segundos
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      _mensaje = 'Verificando seguridad...';
    });

    // Comprobar biometría
    final disponible =
        await _biometricService.puedeAutenticar();

    if (!mounted) return;

    if (!disponible) {
      setState(() {
        _mensaje =
            'La biometría no está disponible';
      });

      return;
    }

    // Iniciar autenticación
    setState(() {
      _autenticando = true;
      _mensaje = 'Desbloquea SafePass';
    });

    final autenticado =
        await _biometricService.autenticar();

    if (!mounted) return;

    if (autenticado) {
      // MUY IMPORTANTE:
      // dejamos terminar completamente
      // la autenticación antes de navegar.

      setState(() {
        _mensaje = 'Acceso concedido';
      });

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        _autenticando = false;
        _mensaje =
            'No se pudo desbloquear SafePass';
      });
    }
  }

  Future<void> _reintentar() async {
    setState(() {
      _autenticando = true;
      _mensaje = 'Desbloquea SafePass';
    });

    final autenticado =
        await _biometricService.autenticar();

    if (!mounted) return;

    if (autenticado) {
      setState(() {
        _mensaje = 'Acceso concedido';
      });

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        _autenticando = false;
        _mensaje =
            'Autenticación cancelada';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'SafePass',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _mensaje,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 35),

                if (_autenticando)
                  const CircularProgressIndicator(),

                if (!_autenticando &&
                    _mensaje.contains(
                      'No se pudo',
                    ))
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _reintentar,
                      icon: const Icon(
                        Icons.fingerprint,
                      ),
                      label: const Text(
                        'Intentar nuevamente',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}