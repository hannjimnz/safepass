import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/service_options.dart';
import '../models/password.dart';
import '../providers/password_provider.dart';
import '../widgets/password_generator_dialog.dart';

class AddPasswordScreen extends StatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  State<AddPasswordScreen> createState() =>
      _AddPasswordScreenState();
}

class _AddPasswordScreenState
    extends State<AddPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController servicioController =
      TextEditingController();

  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController claveController =
      TextEditingController();

  final TextEditingController notasController =
      TextEditingController();

  String? servicioSeleccionado;

  String categoriaSeleccionada = 'Personal';

  final List<String> categorias = [
    'Personal',
    'Trabajo',
    'Estudio',
    'Redes sociales',
    'Bancos',
    'Otros',
  ];

  bool mostrarPassword = false;
  bool mostrarClave = false;

  Future<void> _generarPassword() async {
    final passwordGenerada = await showDialog<String>(
      context: context,
      builder: (_) => const PasswordGeneratorDialog(),
    );

    if (!mounted || passwordGenerada == null) return;

    passwordController.text = passwordGenerada;
  }

  @override
  void dispose() {
    servicioController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    claveController.dispose();
    notasController.dispose();

    super.dispose();
  }

  Future<void> guardarPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = Password(
      servicio: servicioSeleccionado == otherServiceOption
          ? servicioController.text.trim()
          : servicioSeleccionado!,
      usuario: usuarioController.text.trim(),
      password: passwordController.text,
      clave: claveController.text,
      categoria: categoriaSeleccionada,
      notas: notasController.text.trim(),
      icono: null,
      fechaCreacion: DateTime.now(),
    );

    await context
        .read<PasswordProvider>()
        .agregarPassword(password);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva contraseña'),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                'Información de la cuenta',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                initialValue: servicioSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Servicio',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecciona un servicio'),
                items: availableServices.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio,
                    child: Text(servicio),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    servicioSeleccionado = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un servicio';
                  }
                  return null;
                },
              ),

              if (servicioSeleccionado == otherServiceOption) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: servicioController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del servicio',
                    hintText: 'Escribe el nombre del servicio',
                    prefixIcon: Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (servicioSeleccionado == otherServiceOption &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Escribe el nombre del servicio';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: usuarioController,

                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ej. usuario@gmail.com',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ingresa el usuario';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,

                obscureText: !mostrarPassword,

                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: mostrarPassword
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        icon: Icon(
                          mostrarPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            mostrarPassword = !mostrarPassword;
                          });
                        },
                      ),
                      IconButton(
                        tooltip: 'Generar contraseña',
                        icon: const Icon(Icons.auto_awesome),
                        onPressed: _generarPassword,
                      ),
                    ],
                  ),

                  border: const OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Ingresa la contraseña';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: claveController,

                  obscureText: !mostrarClave,

                  decoration: InputDecoration(
                    labelText: 'Clave (opcional)',
                    hintText: 'Clave adicional',

                    prefixIcon: const Icon(
                      Icons.key,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarClave
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          mostrarClave = !mostrarClave;
                        });
                      },
                    ),

                    border: const OutlineInputBorder(),
                  ),
                ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: categoriaSeleccionada,

                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),

                items: categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      categoriaSeleccionada =
                          value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: notasController,

                maxLines: 4,

                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText:
                      'Información adicional...',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(
                  onPressed: guardarPassword,

                  icon: const Icon(Icons.save),

                  label: const Text(
                    'Guardar contraseña',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
