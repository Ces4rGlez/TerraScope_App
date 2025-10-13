import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = ' "http://10.0.2.2:3000/api/usuarios';

  /// Retorna un Map con los datos del usuario si el login es correcto, o null si falla
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
          // Devuelve solo los campos que necesitamos
          return {
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
