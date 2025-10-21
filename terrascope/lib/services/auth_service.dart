import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://192.168.0.176/api/usuarios';

  /// Retorna un Map con los datos completos del usuario incluyendo el ID
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
          // ✅ CAMBIO: Ahora incluye el _id del usuario
          return {
            'id_usuario': usuario['_id'], // ✅ NUEVO
            'nombre_usuario': usuario['nombre_usuario'],
            'email_usuario': usuario['email_usuario'],
          };
        }
        return null;
      } else {
        print('Error de servidor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }
}
