import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/password.dart';
import '../providers/password_provider.dart';
import 'edit_password_screen.dart';

class PasswordDetailScreen extends StatefulWidget {
  final Password password;

  const PasswordDetailScreen({
    super.key,
    required this.password,
  });

  @override
  State<PasswordDetailScreen> createState() =>
      _PasswordDetailScreenState();
}

class _PasswordDetailScreenState
    extends State<PasswordDetailScreen> {

  late Password password;

  bool mostrarPassword = false;
  bool mostrarClave = false;

  @override
  void initState() {
    super.initState();

    password = widget.password;
  }

  Future<void> eliminarPassword() async {
    final confirmar = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar contraseña',
          ),

          content: Text(
            '¿Seguro que deseas eliminar la contraseña de ${password.servicio}?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'Cancelar',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    if (!mounted) return;

    await context
        .read<PasswordProvider>()
        .eliminarPassword(password.id!);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget construirCampo(
    String titulo,
    String valor,
    IconData icono, {
    bool oculto = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [

          Icon(
            icono,

            color: Theme.of(context)
                .colorScheme
                .primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  titulo,

                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  oculto
                      ? '••••••••••••'
                      : valor,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (onToggle != null)
            IconButton(
              onPressed: onToggle,

              icon: Icon(
                oculto
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Detalles',
        ),

        actions: [

          // BOTÓN EDITAR
          IconButton(
            onPressed: () async {

              final resultado =
                  await Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      EditPasswordScreen(
                    password: password,
                  ),
                ),
              );

              if (resultado == true &&
                  mounted) {

                Navigator.pop(context);
              }
            },

            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),

          // BOTÓN ELIMINAR
          IconButton(
            onPressed: eliminarPassword,

            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ENCABEZADO
            Center(
              child: Column(
                children: [

                  Container(
                    width: 80,
                    height: 80,

                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,

                      borderRadius:
                          BorderRadius.circular(22),
                    ),

                    child: Icon(
                      Icons.lock,

                      size: 42,

                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    password.servicio,

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    password.categoria,

                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // USUARIO
            construirCampo(
              'Usuario',
              password.usuario,
              Icons.person_outline,
            ),

            // CONTRASEÑA
            construirCampo(
              'Contraseña',
              password.password,
              Icons.lock_outline,

              oculto: !mostrarPassword,

              onToggle: () {
                setState(() {
                  mostrarPassword =
                      !mostrarPassword;
                });
              },
            ),

            // CLAVE
            construirCampo(
              'Clave',
              password.clave,
              Icons.key_outlined,

              oculto: !mostrarClave,

              onToggle: () {
                setState(() {
                  mostrarClave =
                      !mostrarClave;
                });
              },
            ),

            // NOTAS
            if (password.notas.isNotEmpty)
              construirCampo(
                'Notas',
                password.notas,
                Icons.notes_outlined,
              ),

            const SizedBox(height: 10),

            // COPIAR
            SizedBox(
              width: double.infinity,
              height: 52,

              child: FilledButton.icon(
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La función de copiar la contraseña se agregará después.',
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.copy,
                ),

                label: const Text(
                  'Copiar contraseña',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}