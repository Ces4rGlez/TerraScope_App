import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/models/avistamiento_model.dart';

class FaunaFloraService {
  final String baseUrl;

  FaunaFloraService({required this.baseUrl});

  /// Crear nuevo avistamiento
  Future<Avistamiento?> createFaunaFlora(Avistamiento data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fauna-flora'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final jsonData = responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;
        return Avistamiento.fromJson(jsonData);
      } else {
        throw Exception('Error al crear avistamiento: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Votar por un avistamiento (comunidad)
  Future<void> votarAvistamiento(
    String idAvistamiento,
    String idUsuario,
  ) async {
    final url = Uri.parse('$baseUrl/fauna-flora/$idAvistamiento/votar');

    try {
      print("📡 Enviando voto comunidad → $url");
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_usuario': idUsuario}),
      );

      print("📬 Respuesta voto: [${response.statusCode}] ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Error al votar: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error en votarAvistamiento: $e");
      rethrow;
    }
  }

  /// 🔹 Validar avistamiento como experto
  Future<void> validarComoExperto(
    String idAvistamiento,
    String idUsuario,
    String rol,
  ) async {
    final url = Uri.parse(
      '$baseUrl/fauna-flora/$idAvistamiento/validar-experto',
    );

    try {
      print("📡 Enviando validación experto → $url");
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_usuario': idUsuario, 'rol': rol}),
      );

      print(
        "📬 Respuesta validación experto: [${response.statusCode}] ${response.body}",
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Error al validar como experto: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("❌ Error en validarComoExperto: $e");
      rethrow;
    }
  }

  /// 🔹 Obtener estado de validación (incluye yaVoto y usuarios_validadores)
  Future<Map<String, dynamic>?> getEstadoValidacion(
    String idAvistamiento,
    String idUsuario,
  ) async {
    final url = Uri.parse(
      '$baseUrl/fauna-flora/$idAvistamiento/validacion?userId=$idUsuario',
    );

    try {
      print("📡 GET estado validación → $url");

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print(
        "📬 Respuesta estado validación [${response.statusCode}]: ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Error al obtener estado: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error en getEstadoValidacion: $e");
      rethrow;
    }
  }

  /// Obtener todos los avistamientos
  Future<List<Avistamiento>> getAllFaunaFlora() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> dataList;

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else {
          throw Exception('Formato de respuesta no reconocido');
        }

        return dataList
            .map((json) => Avistamiento.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener avistamientos: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error en getAllFaunaFlora: $e');
      rethrow;
    }
  }

  /// Obtener avistamiento por ID
  Future<Avistamiento?> getFaunaFloraById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final data = responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        return Avistamiento.fromJson(data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Error al obtener avistamiento: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener avistamientos cercanos por ubicación
  Future<List<Avistamiento>> getFaunaFloraCerca(
    double latitud,
    double longitud,
    double distanciaKm,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/cerca/$latitud/$longitud/$distanciaKm'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> dataList;
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else {
          throw Exception('Formato de respuesta no reconocido');
        }

        return dataList
            .map((json) => Avistamiento.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al buscar avistamientos cercanos: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Agregar comentario a un avistamiento
  Future<bool> addComentario(
    String avistamientoId,
    String idUsuario,
    String nombreUsuario,
    String comentario,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fauna-flora/$avistamientoId/comentarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_usuario': idUsuario,
          'nombre_usuario': nombreUsuario,
          'comentario': comentario,
          'fecha': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al agregar comentario: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar avistamiento
  Future<Avistamiento?> updateFaunaFlora(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final jsonData = responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;
        return Avistamiento.fromJson(jsonData as Map<String, dynamic>);
      } else {
        throw Exception(
          'Error al actualizar avistamiento: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar avistamiento
  Future<bool> deleteFaunaFlora(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/fauna-flora/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Error al eliminar avistamiento: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener avistamientos por especie
  Future<List<Avistamiento>> getFaunaFloraByEspecie(String especie) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/especie/$especie'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> dataList;
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else {
          throw Exception('Formato de respuesta no reconocido');
        }

        return dataList
            .map((json) => Avistamiento.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener avistamientos por especie: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener avistamientos por usuario
  Future<List<Avistamiento>> getFaunaFloraByUsuario(
    String nombreUsuario,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fauna-flora/usuario/$nombreUsuario'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        List<dynamic> dataList;
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else {
          throw Exception('Formato de respuesta no reconocido');
        }

        return dataList
            .map((json) => Avistamiento.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error al obtener avistamientos del usuario: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
