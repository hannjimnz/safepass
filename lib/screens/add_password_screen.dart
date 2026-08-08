import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/password.dart';
import '../providers/password_provider.dart';

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
      servicio: servicioController.text.trim(),
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

              TextFormField(
                controller: servicioController,

                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio',
                  hintText: 'Ej. GitHub',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ingresa el nombre del servicio';
                  }

                  return null;
                },
              ),

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

                  suffixIcon: IconButton(
                    icon: Icon(
                      mostrarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),

                    onPressed: () {
                      setState(() {
                        mostrarPassword =
                            !mostrarPassword;
                      });
                    },
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

                obscureText: true,

                decoration: const InputDecoration(
                  labelText: 'Clave',
                  hintText: 'Clave adicional',
                  prefixIcon: Icon(Icons.key),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Ingresa la clave';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: categoriaSeleccionada,

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