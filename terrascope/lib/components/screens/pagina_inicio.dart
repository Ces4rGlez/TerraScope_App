import 'package:flutter/material.dart';
import '../map/map_page.dart';

class HomePage extends StatelessWidget {
  final String? idUsuario;
  final String nombreUsuario;
  final String emailUsuario;

  const HomePage({
    super.key,
    this.idUsuario,
    required this.nombreUsuario,
    required this.emailUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final id = args?['id_usuario'] ?? idUsuario;
    final nombre = args?['nombre_usuario'] ?? nombreUsuario;
    final email = args?['email_usuario'] ?? emailUsuario;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF224275),
        title: const Text(
          "Inicio",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Color(0xFF5C6445),
              ),
              const SizedBox(height: 20),
              Text(
                "¡Bienvenido, $nombre!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF224275),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                email,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F1D33)),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF939E69),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "Nos alegra verte de nuevo. Explora el contenido y sigue contribuyendo a la protección de nuestra fauna y flora 🌱",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF224275),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: {'id_usuario': id, 'nombre_usuario': nombre},
                  );
                },
                icon: const Icon(Icons.pets, color: Colors.white),
                label: const Text(
                  "Ver fauna y flora",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
