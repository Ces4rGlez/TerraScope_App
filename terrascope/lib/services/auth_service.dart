import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terrascope/config/api_config.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/usuarios';

  /// 🔹 LOGIN (valida usuario por email y contraseña)
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> usuarios = json.decode(response.body);

        final usuario = usuarios.firstWhere(
          (u) =>
              u['email_usuario'] == email &&
              u['contrasenia_usuario'] == password,
          orElse: () => null,
        );

        if (usuario != null) {
          final userData = {
            '_id': usuario['_id'], // 👈 importante para validación
            'nombre_usuario': usuario['nombre_usuario'],
            'email_usuario': usuario['email_usuario'],
            'rol_usuario': usuario['rol']?['nombre_rol'] ?? 'Usuario',
          };

          print('✅ Usuario autenticado: $userData');
          return userData;
        } else {
          print('⚠️ Usuario no encontrado o credenciales inválidas.');
          return null;
        }
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error al iniciar sesión: $e');
      return null;
    }
  }

  /// 🔹 CREAR USUARIO
  Future<bool> crearUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuarioData),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error al crear usuario: $e');
      return false;
    }
  }

  /// 🔹 OBTENER TODOS LOS USUARIOS
  Future<List<dynamic>> obtenerUsuarios() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al obtener usuarios: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  /// 🔹 OBTENER USUARIO POR ID
  Future<Map<String, dynamic>?> obtenerUsuarioPorId(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Usuario no encontrado (${response.statusCode})');
        return null;
      }
    } catch (e) {
      print('Error al obtener usuario por ID: $e');
      return null;
    }
  }

  /// 🔹 ACTUALIZAR USUARIO
  Future<bool> actualizarUsuario(String id, Map<String, dynamic> datosActualizados) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosActualizados),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar usuario: $e');
      return false;
    }
  }

  /// 🔹 ELIMINAR USUARIO
  Future<bool> eliminarUsuario(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar usuario: $e');
      return false;
    }
  }
}
