import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class TestUsuariosPage extends StatefulWidget {
  const TestUsuariosPage({super.key});

  @override
  State<TestUsuariosPage> createState() => _TestUsuariosPageState();
}

class _TestUsuariosPageState extends State<TestUsuariosPage> {
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() async {
    try {
      final data = await ApiService.getUsuarios();
      setState(() {
        usuarios = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios")),
      body: ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final user = usuarios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                // Aquí convertimos el objeto a JSON con indentación
                JsonEncoder.withIndent('  ').convert(user),
                style: const TextStyle(fontSize: 14, fontFamily: 'Courier'),
              ),
            ),
          );
        },
      ),
    );
  }
}
