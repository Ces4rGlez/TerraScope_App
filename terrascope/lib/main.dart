import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terrascope/components/screens/login_page.dart';
import 'package:terrascope/components/screens/pagina_inicio.dart';
import 'package:terrascope/components/screens/profile_page.dart';
import 'package:terrascope/components/screens/register_page.dart';
import 'package:terrascope/components/screens/retos_activos_screen.dart';
import 'package:terrascope/components/screens/logros_screen.dart';
import 'package:terrascope/providers/retos_observer_provider.dart';
import 'components/map/map_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RetosObserverProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileScreen(),
        
        '/retos': (context) => const RetosActivosScreen(),
        '/logros': (context) => const LogrosScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {}

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
