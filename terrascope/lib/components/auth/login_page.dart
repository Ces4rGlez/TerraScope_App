import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF5C6445), // fondo principal
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Logo y título (fuera del card)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "TerraScope",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE0E0E0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      "assets/logo.png",
                      height: 45,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 🔹 CARD CONTENEDOR DEL LOGIN
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 Título
                        const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F1D33),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // 🔹 Descripción
                        const Text(
                          "Ingresa tus datos para acceder a tu cuenta",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF224275),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Campo de correo
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Correo electrónico",
                            labelStyle: const TextStyle(color: Color(0xFF5C6445)),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF5C6445),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF939E69),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF939E69),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF224275),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Campo de contraseña
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Contraseña",
                            labelStyle: const TextStyle(color: Color(0xFF5C6445)),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF5C6445),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF939E69),
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF939E69),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF224275),
                                width: 2,
                              ),
                            ),
                          ),
                          obscureText: true,
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Botón Continuar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final email = emailController.text;
                              final password = passwordController.text;

                              if (email.isNotEmpty && password.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Correo: $email\nContraseña: $password"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Por favor ingresa todos los campos."),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F1D33),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Continuar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Botón para ir a registro
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: "¿No tienes cuenta? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF224275),
                                ),
                                children: [
                                  TextSpan(
                                    text: "Regístrate",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0F1D33),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Texto de términos y políticas (fuera del card)
                const Text(
                  "Al hacer clic en continuar, aceptas nuestros\nTérminos de servicio y Política de privacidad.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}