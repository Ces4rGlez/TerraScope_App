import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000/api"; // Cambia a tu IP si pruebas en móvil

  // obtener todos los usuarios
  static Future<List<dynamic>> getUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

  static Future<List<dynamic>> getFaunaFlora() async{
    final responde =await http.get(Uri.parse('$baseUrl/fauna-flora'));

        if (responde.statusCode == 200) {
      return json.decode(responde.body);
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }


}