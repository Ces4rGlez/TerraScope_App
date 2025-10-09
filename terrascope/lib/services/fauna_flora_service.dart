import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/models/fauna_flora_data.dart';

class FaunaFloraService {
  final String baseUrl;

  FaunaFloraService({required this.baseUrl});

  // Crear nuevo avistamiento
  Future<FaunaFloraData?> createFaunaFlora(FaunaFloraData data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fauna-flora'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return FaunaFloraData.fromJson(responseData['data']);
      } else {
        throw Exception('Error al crear avistamiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtener todos los avistamientos
  Future<List<FaunaFloraData>> getAllFaunaFlora() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> dataList = responseData['data'];
        return dataList.map((json) => FaunaFloraData.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener avistamientos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtener avistamiento por ID
  Future<FaunaFloraData?> getFaunaFloraById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return FaunaFloraData.fromJson(responseData['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener avistamiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Obtener avistamientos cercanos
  Future<List<FaunaFloraData>> getFaunaFloraCerca(
    double latitud,
    double longitud,
    double distanciaKm,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/cerca/$latitud/$longitud/$distanciaKm'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> dataList = responseData['data'];
        return dataList.map((json) => FaunaFloraData.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar avistamientos cercanos: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Agregar comentario
  Future<bool> addComentario(
    String avistamientoId,
    String idUsuario,
    String nombreUsuario,
    String comentario,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fauna-flora/$avistamientoId/comentarios'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_usuario': idUsuario,
          'nombre_usuario': nombreUsuario,
          'comentario': comentario,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al agregar comentario: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Actualizar avistamiento
  Future<FaunaFloraData?> updateFaunaFlora(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return FaunaFloraData.fromJson(responseData['data']);
      } else {
        throw Exception('Error al actualizar avistamiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar avistamiento
  Future<bool> deleteFaunaFlora(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al eliminar avistamiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
