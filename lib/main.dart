import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/password_provider.dart';
import 'providers/context_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provider de las contraseñas
        ChangeNotifierProvider(
          create: (_) => PasswordProvider(),
        ),

        // Provider del contexto
        ChangeNotifierProvider(
          create: (_) => ContextProvider()
            ..inicializarContexto(),
        ),
      ],
      child: const PasswordVaultApp(),
    ),
  );
}

class PasswordVaultApp extends StatelessWidget {
  const PasswordVaultApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el contexto actual
    final esModoNocturno =
        context.watch<ContextProvider>()
            .esModoNocturno;

    return MaterialApp(
      title: 'Password Vault',

      debugShowCheckedModeBanner: false,

      // ======================================================
      // TEMA SEGÚN EL CONTEXTO
      // ======================================================

      theme: esModoNocturno
          ? ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.dark,

              appBarTheme:
                  const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            )
          : ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.indigo,
              brightness: Brightness.light,

              scaffoldBackgroundColor:
                  Colors.grey.shade100,

              appBarTheme:
                  const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),

      home: const SplashScreen(),
    );
  }
}