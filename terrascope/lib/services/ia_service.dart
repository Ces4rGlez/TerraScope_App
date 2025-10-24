import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class IAService {
  /// Envía una imagen en base64 al backend para identificar la especie.
  /// Devuelve un mapa con el nombre científico, común y el nivel de confianza.
  static Future<Map<String, dynamic>> identificarEspecie(String imagenBase64) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/ia/identificar');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'imagen': imagenBase64}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {
        'nombre_cientifico': data['nombre_cientifico'] ?? 'Desconocido',
        'nombre_comun': data['nombre_comun'] ?? 'Desconocido',
        'nivel_confianza': data['nivel_confianza'] ?? 'Desconocido',
      };
    } else {
      throw Exception(
        'Error al identificar la especie: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
