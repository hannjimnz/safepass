import 'package:flutter/material.dart';

import '../services/biometric_service.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const BiometricLockScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState
    extends State<BiometricLockScreen> {
  final BiometricService _biometricService =
      BiometricService();

  bool _cargando = true;
  bool _autenticando = false;
  bool _puedeAutenticar = false;
  bool _yaAutenticado = false;

  @override
  void initState() {
    super.initState();

    _prepararAutenticacion();
  }

  // ============================================================
  // PREPARAR AUTENTICACIÓN
  // ============================================================

  Future<void> _prepararAutenticacion() async {
    final disponible =
        await _biometricService.puedeAutenticar();

    if (!mounted) return;

    setState(() {
      _puedeAutenticar = disponible;
      _cargando = false;
    });

    if (disponible) {
      await _autenticar();
    }
  }

  // ============================================================
  // AUTENTICAR
  // ============================================================

  Future<void> _autenticar() async {
    if (_autenticando || _yaAutenticado) {
      return;
    }

    setState(() {
      _autenticando = true;
    });

    final autenticado =
        await _biometricService.autenticar();

    if (!mounted) return;

    setState(() {
      _autenticando = false;
    });

    if (autenticado) {
      // Evita que la autenticación se vuelva a ejecutar.
      _yaAutenticado = true;

      // Esperamos un momento para asegurarnos de que
      // el diálogo biométrico ya terminó.
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo autenticar. Inténtalo nuevamente.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

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
                // ICONO
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

                const SizedBox(height: 10),

                Text(
                  'Tu bóveda de contraseñas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 50),

                // CARGANDO
                if (_cargando)
                  const CircularProgressIndicator()

                // BIOMETRÍA NO DISPONIBLE
                else if (!_puedeAutenticar)
                  Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 55,
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'La biometría no está disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Configura una huella o reconocimiento facial en tu dispositivo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )

                // BIOMETRÍA DISPONIBLE
                else
                  Column(
                    children: [
                      const Text(
                        'Desbloquea SafePass',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton.icon(
                          onPressed:
                              _autenticando ||
                                      _yaAutenticado
                                  ? null
                                  : _autenticar,
                          icon: const Icon(
                            Icons.fingerprint,
                            size: 28,
                          ),
                          label: Text(
                            _autenticando
                                ? 'Autenticando...'
                                : 'Usar biometría',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}