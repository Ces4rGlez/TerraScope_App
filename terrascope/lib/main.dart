import 'package:flutter/material.dart';
import 'components/auth/register_page.dart';
import 'components/auth/login_page.dart';
import 'components/map/map_page.dart';

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
        '/map': (context) => const MapPage(),
      },
      //Aquí se usa onGenerateRoute para pasar los datos dinámicos
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomePage(
              nombreUsuario: args['nombre_usuario'] ?? 'Desconocido',
              emailUsuario: args['email_usuario'] ?? 'sin_correo@example.com',
            ),
          );
        }
        return null;
      },
    );
  }
}
