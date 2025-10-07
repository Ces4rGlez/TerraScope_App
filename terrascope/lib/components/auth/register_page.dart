import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF5C6445), // fondo principal
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Logo y título
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "TerraScope",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    "assets/logo.png",
                    height: 40,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 🔹 Título
              const Text(
                "Crear cuenta",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE0E0E0),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Descripción
              const Text(
                "Ingresa tu correo electrónico para registrarte en esta aplicación",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFE0E0E0),
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Campo de correo
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE0E0E0),
                  labelText: "Correo electrónico",
                  labelStyle: const TextStyle(color: Color(0xFF0F1D33)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // 🔹 Botón Continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final email = emailController.text;
                    if (email.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Correo ingresado: $email")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor ingresa un correo válido.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1D33),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continuar",
                    style: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Botón de iniciar sesión
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF939E69),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 🔹 Texto de términos y políticas
              const Center(
                child: Text(
                  "Al hacer clic en continuar, aceptas nuestros\nTérminos de servicio y Política de privacidad.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE0E0E0),
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
