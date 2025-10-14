import 'package:flutter/material.dart';
import 'components/auth/register_page.dart';
import 'components/auth/login_page.dart';
import 'components/map/map_page.dart';
import 'components/screens/pagina_inicio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TerraScope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomePage(
              idUsuario: args['id_usuario'],
              nombreUsuario: args['nombre_usuario'] ?? 'Desconocido',
              emailUsuario: args['email_usuario'] ?? 'sin_correo@example.com',
            ),
          );
        }

        if (settings.name == '/map') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MapPage(
              usuarioId: args?['id_usuario'],
              nombreUsuario: args?['nombre_usuario'],
            ),
          );
        }

        return null;
      },
    );
  }
}
