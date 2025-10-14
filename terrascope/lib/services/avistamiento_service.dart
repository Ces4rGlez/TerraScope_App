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

  static Future<void> addComentario(
    String avistamientoId,
    String? usuarioId,
    String nombreUsuario,
    String comentario,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/fauna-flora/$avistamientoId/comentarios'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (usuarioId != null &&
            usuarioId.isNotEmpty &&
            usuarioId != '000000000000000000000000')
          'id_usuario': usuarioId,
        'nombre_usuario': nombreUsuario,
        'comentario': comentario,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al agregar comentario: ${response.body}');
    }
  }

  // ✅ NUEVO: Búsqueda de avistamientos
  static Future<List<Avistamiento>> searchAvistamientos(String query) async {
    final avistamientos = await getAvistamientos();

    return avistamientos.where((avistamiento) {
      return avistamiento.nombreComun.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          avistamiento.nombreCientifico.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          avistamiento.especie.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
