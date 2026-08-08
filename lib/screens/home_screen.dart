import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/password_provider.dart';
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

    final provider =
        context.watch<PasswordProvider>();

    final passwords =
        provider.buscarPasswords(textoBusqueda);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Password Vault',
        ),

        actions: [

          IconButton(
            onPressed: () {
              // Más adelante agregaremos configuración.
            },

            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // BUSCADOR
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
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
                              searchController.clear();

                              setState(() {
                                textoBusqueda = '';
                              });
                            },

                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // CONTENIDO
          Expanded(
            child: provider.isLoading

                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )

                : passwords.isEmpty

                    ? _construirEstadoVacio()

                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),

                        itemCount:
                            passwords.length,

                        itemBuilder:
                            (context, index) {

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
                                    password:
                                        password,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              context
                                  .read<
                                      PasswordProvider>()
                                  .cargarPasswords();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),

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

          if (!mounted) return;

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

            const SizedBox(height: 20),

            Text(
              estaBuscando
                  ? 'No se encontraron resultados'
                  : 'Tu bóveda está vacía',

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              estaBuscando
                  ? 'Intenta buscar con otro término.'
                  : 'Agrega tu primera contraseña para comenzar.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}