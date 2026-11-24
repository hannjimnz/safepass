import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/backup_service.dart';
import '../providers/app_lock_provider.dart';
import '../providers/password_provider.dart';
import '../providers/context_provider.dart';

import '../widgets/backup_passphrase_dialog.dart';
import '../widgets/password_card.dart';

import 'add_password_screen.dart';
import 'password_detail_screen.dart';

enum _BackupAction { export, restore }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String textoBusqueda = '';

  final BackupService _backupService = BackupService();
  bool _procesandoRespaldo = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context
            .read<PasswordProvider>()
            .cargarPasswords();
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<String?> _pedirFraseRespaldo({
    required bool confirmar,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => BackupPassphraseDialog(
        confirmPassphrase: confirmar,
      ),
    );
  }

  Future<void> _exportarRespaldo() async {
    final provider = context.read<PasswordProvider>();
    if (provider.isLoading) {
      _mostrarMensaje('Espera a que termine de cargar la bóveda.');
      return;
    }

    setState(() => _procesandoRespaldo = true);
    try {
      final frase = await _pedirFraseRespaldo(confirmar: true);
      if (!mounted || frase == null) return;

      final bytes = await _backupService.crearRespaldo(
        provider.passwords,
        frase,
      );
      if (!mounted) return;

      final now = DateTime.now();
      final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final appLock = context.read<AppLockProvider>();
      final savedFile = await appLock.runWithSystemFilePicker(
        () => FilePicker.saveFile(
          dialogTitle: 'Guardar respaldo de SafePass',
          fileName: 'safepass-backup-$date.safepass',
          type: FileType.custom,
          allowedExtensions: ['safepass'],
          bytes: bytes,
        ),
      );

      if (!mounted || appLock.isLocked) return;
      if (savedFile != null) {
        _mostrarMensaje('Respaldo cifrado guardado.');
      }
    } catch (error) {
      _mostrarMensaje('No se pudo crear el respaldo: $error');
    } finally {
      if (mounted) setState(() => _procesandoRespaldo = false);
    }
  }

  Future<void> _importarRespaldo() async {
    final provider = context.read<PasswordProvider>();
    if (provider.isLoading) {
      _mostrarMensaje('Espera a que termine de cargar la bóveda.');
      return;
    }

    setState(() => _procesandoRespaldo = true);
    try {
      final appLock = context.read<AppLockProvider>();
      final selection = await appLock.runWithSystemFilePicker(
        () => FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['safepass'],
          withReadStream: true,
        ),
      );
      if (!mounted ||
          appLock.isLocked ||
          selection == null ||
          selection.files.isEmpty) {
        return;
      }

      final file = selection.files.single;
      if (file.size > BackupService.maxBackupSizeBytes) {
        _mostrarMensaje('El archivo supera el tamaño máximo permitido.');
        return;
      }

      final stream = file.readStream;
      if (stream == null) {
        _mostrarMensaje('No se pudo leer el archivo seleccionado.');
        return;
      }

      final builder = BytesBuilder(copy: false);
      var totalBytes = 0;
      await for (final chunk in stream) {
        totalBytes += chunk.length;
        if (totalBytes > BackupService.maxBackupSizeBytes) {
          _mostrarMensaje('El archivo supera el tamaño máximo permitido.');
          return;
        }
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();

      final frase = await _pedirFraseRespaldo(confirmar: false);
      if (!mounted || frase == null) return;

      final passwords = await _backupService.abrirRespaldo(bytes, frase);
      if (!mounted) return;

      final shouldReplace = await _confirmarRestauracion(
        cantidadActual: provider.passwords.length,
        cantidadRespaldo: passwords.length,
      );
      if (!mounted || shouldReplace != true) return;

      await provider.restaurarPasswords(passwords);
      if (!mounted) return;

      _mostrarMensaje(
        'Se restauraron ${passwords.length} credenciales.',
      );
    } catch (error) {
      _mostrarMensaje('No se pudo restaurar el respaldo: $error');
    } finally {
      if (mounted) setState(() => _procesandoRespaldo = false);
    }
  }

  Future<bool?> _confirmarRestauracion({
    required int cantidadActual,
    required int cantidadRespaldo,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reemplazar la bóveda'),
        content: Text(
          'El respaldo contiene $cantidadRespaldo credenciales. '
          'Se reemplazarán las $cantidadActual credenciales actuales. '
          'Esta acción no se puede deshacer desde SafePass.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reemplazar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // CONTEXTO DE LA APLICACIÓN
    // ============================================================

    final contexto =
        context.watch<ContextProvider>();

    // ============================================================
    // PASSWORD PROVIDER
    // ============================================================

    final provider =
        context.watch<PasswordProvider>();

    final passwords =
        provider.buscarPasswords(
      textoBusqueda,
    );

    return Scaffold(
      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        title: const Text(
          'Password Vault',
        ),
        actions: [
          if (_procesandoRespaldo)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<_BackupAction>(
              tooltip: 'Respaldos',
              icon: const Icon(Icons.backup_outlined),
              onSelected: (action) {
                if (action == _BackupAction.export) {
                  unawaited(_exportarRespaldo());
                } else {
                  unawaited(_importarRespaldo());
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _BackupAction.export,
                  child: Text('Crear respaldo cifrado'),
                ),
                PopupMenuItem(
                  value: _BackupAction.restore,
                  child: Text('Restaurar respaldo'),
                ),
              ],
            ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Column(
        children: [
          // ======================================================
          // BUSCADOR
          // ======================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              8,
            ),
            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  textoBusqueda = value;
                });
              },

              decoration: InputDecoration(
                hintText:
                    'Buscar contraseña...',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    textoBusqueda.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController
                                  .clear();

                              setState(() {
                                textoBusqueda =
                                    '';
                              });
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                filled: true,

                fillColor:
                    Theme.of(context)
                        .colorScheme
                        .surface,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // ======================================================
          // CONTEXTO
          // ======================================================

          Container(
            width: double.infinity,

            margin: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),

            padding:
                const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: contexto.esModoNocturno
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                  : Theme.of(context)
                      .colorScheme
                      .primaryContainer,

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Row(
              children: [
                // ICONO
                Container(
                  width: 48,
                  height: 48,

                  decoration:
                      BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: Icon(
                    contexto.esModoNocturno
                        ? Icons
                            .nightlight_round
                        : Icons
                            .wb_sunny_outlined,

                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(width: 14),

                // TEXTO
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        contexto.saludo,

                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        contexto.mensaje,

                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // CONTENIDO
          // ======================================================

          Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : passwords.isEmpty
                        ? _construirEstadoVacio()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: passwords.length,
                            itemBuilder: (context, index) {
                              final password =
                                  passwords[index];

                              return PasswordCard(
                                password: password,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PasswordDetailScreen(
                                        password: password,
                                      ),
                                    ),
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  context
                                      .read<PasswordProvider>()
                                      .cargarPasswords();
                                },
                              );
                            },
                          ),
              ),

          // CRÉDITOS
          const Padding(
            padding: EdgeInsets.only(
              top: 6,
              bottom: 10,
            ),
            child: Text(
              'by Hannia Jimenez & Jazmin Gutierrez',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),

      // ==========================================================
      // BOTÓN AGREGAR
      // ==========================================================

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _procesandoRespaldo
            ? null
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddPasswordScreen(),
                  ),
                );

                if (!mounted) return;

                context.read<PasswordProvider>().cargarPasswords();
              },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  // =============================================================
  // ESTADO VACÍO
  // =============================================================

  Widget _construirEstadoVacio() {
    final estaBuscando =
        textoBusqueda.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              estaBuscando
                  ? Icons.search_off
                  : Icons.lock_outline,

              size: 80,

              color: Colors.grey.shade400,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              estaBuscando
                  ? 'No se encontraron resultados'
                  : 'Tu bóveda está vacía',

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              estaBuscando
                  ? 'Intenta buscar con otro término.'
                  : 'Agrega tu primera contraseña para comenzar.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
