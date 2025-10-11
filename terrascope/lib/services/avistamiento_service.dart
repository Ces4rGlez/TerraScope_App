import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/avistamiento_model.dart';
import '../config/api_config.dart';

class AvistamientoService {
  static Future<List<Avistamiento>> getAvistamientos({String? especie}) async {
    String url = '${ApiConfig.baseUrl}/fauna-flora';
    if (especie != null) {
      url += '?categoria=$especie';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Avistamiento.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar avistamientos');
    }
  }

  static Future<Avistamiento> getAvistamientoById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/fauna-flora/$id'),
    );

    if (response.statusCode == 200) {
      return Avistamiento.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar avistamiento');
    }
  }

  static Future<List<ZonaFrecuente>> getZonasFrecuentes() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/fauna-flora/frequent-zones'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ZonaFrecuente.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar zonas frecuentes');
    }
  }
}
