import 'package:flutter/material.dart';

import 'add_password_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Password Vault"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.security,
              size: 90,
              color: Colors.indigo,
            ),

            SizedBox(height: 20),

            Text(
              "No hay contraseñas almacenadas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Presiona el botón + para agregar una.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddPasswordScreen(),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}