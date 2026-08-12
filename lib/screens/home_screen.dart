import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/password_provider.dart';
import '../providers/context_provider.dart';

import '../widgets/password_card.dart';

import 'add_password_screen.dart';
import 'password_detail_screen.dart';

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

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddPasswordScreen(),
            ),
          );

          if (!mounted) {
            return;
          }

          context
              .read<PasswordProvider>()
              .cargarPasswords();
        },

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'Agregar',
        ),
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