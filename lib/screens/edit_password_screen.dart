import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/service_options.dart';
import '../models/password.dart';
import '../providers/password_provider.dart';
import '../widgets/password_generator_dialog.dart';

class EditPasswordScreen extends StatefulWidget {
  final Password password;

  const EditPasswordScreen({
    super.key,
    required this.password,
  });

  @override
  State<EditPasswordScreen> createState() =>
      _EditPasswordScreenState();
}

class _EditPasswordScreenState
    extends State<EditPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController servicioController;
  late TextEditingController usuarioController;
  late TextEditingController passwordController;
  late TextEditingController claveController;
  late TextEditingController notasController;

  late String servicioSeleccionado;
  late String categoriaSeleccionada;

  bool mostrarPassword = false;

  Future<void> _generarPassword() async {
    final passwordGenerada = await showDialog<String>(
      context: context,
      builder: (_) => const PasswordGeneratorDialog(),
    );

    if (!mounted || passwordGenerada == null) return;

    passwordController.text = passwordGenerada;
  }

  final List<String> categorias = [
    'Personal',
    'Trabajo',
    'Estudio',
    'Redes sociales',
    'Bancos',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();

    servicioSeleccionado =
        predefinedServices.contains(widget.password.servicio)
            ? widget.password.servicio
            : otherServiceOption;

    servicioController = TextEditingController(
      text: servicioSeleccionado == otherServiceOption
          ? widget.password.servicio
          : '',
    );

    usuarioController = TextEditingController(
      text: widget.password.usuario,
    );

    passwordController = TextEditingController(
      text: widget.password.password,
    );

    claveController = TextEditingController(
      text: widget.password.clave,
    );

    notasController = TextEditingController(
      text: widget.password.notas,
    );

    categoriaSeleccionada =
        widget.password.categoria;
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

  Future<void> actualizarPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final passwordActualizada = Password(
      id: widget.password.id,

      servicio: servicioSeleccionado == otherServiceOption
          ? servicioController.text.trim()
          : servicioSeleccionado,

      usuario: usuarioController.text.trim(),

      password: passwordController.text,

      clave: claveController.text,

      categoria: categoriaSeleccionada,

      notas: notasController.text.trim(),

      icono: widget.password.icono,

      fechaCreacion:
          widget.password.fechaCreacion,
    );

    await context
        .read<PasswordProvider>()
        .actualizarPassword(passwordActualizada);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar contraseña',
        ),
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
                'Editar información',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // SERVICIO
              DropdownButtonFormField<String>(
                initialValue: servicioSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Servicio',
                  prefixIcon: Icon(Icons.language),
                  border: OutlineInputBorder(),
                ),
                items: availableServices.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio,
                    child: Text(servicio),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      servicioSeleccionado = value;
                    });
                  }
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
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe el nombre del servicio';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 16),

              // USUARIO
              TextFormField(
                controller: usuarioController,

                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon:
                      Icon(Icons.person),
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

              // CONTRASEÑA
              TextFormField(
                controller: passwordController,

                obscureText: !mostrarPassword,

                decoration: InputDecoration(
                  labelText: 'Contraseña',

                  prefixIcon:
                      const Icon(Icons.lock),

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

                  border:
                      const OutlineInputBorder(),
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

              // CLAVE
              TextFormField(
                controller: claveController,

                obscureText: true,

                decoration: const InputDecoration(
                  labelText: 'Clave (opcional)',

                  prefixIcon:
                      Icon(Icons.key),

                  border:
                      OutlineInputBorder(),
                ),

              ),

              const SizedBox(height: 16),

              // CATEGORÍA
              DropdownButtonFormField<String>(
                initialValue: categoriaSeleccionada,

                decoration:
                    const InputDecoration(
                  labelText: 'Categoría',

                  prefixIcon:
                      Icon(Icons.category),

                  border:
                      OutlineInputBorder(),
                ),

                items: categorias.map(
                  (categoria) {
                    return DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    );
                  },
                ).toList(),

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

              // NOTAS
              TextFormField(
                controller: notasController,

                maxLines: 4,

                decoration:
                    const InputDecoration(
                  labelText: 'Notas',

                  prefixIcon:
                      Icon(Icons.notes),

                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // BOTÓN
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed:
                      actualizarPassword,

                  icon:
                      const Icon(Icons.save),

                  label: const Text(
                    'Guardar cambios',

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
