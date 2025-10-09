import 'ubicacion.dart';
import 'habitat.dart';
import 'comentario.dart';

class FaunaFloraData {
  final String? id;
  final String nombreComun;
  final String nombreCientifico;
  final String especie;
  final String descripcion;
  final String imagenBase64;
  final Ubicacion ubicacion;
  final String comportamiento;
  final String estadoExtincion;
  final String estadoEspecimen;
  final Habitat habitad;
  final List<Comentario>? comentarios;

  FaunaFloraData({
    this.id,
    required this.nombreComun,
    required this.nombreCientifico,
    required this.especie,
    required this.descripcion,
    required this.imagenBase64,
    required this.ubicacion,
    required this.comportamiento,
    required this.estadoExtincion,
    required this.estadoEspecimen,
    required this.habitad,
    this.comentarios,
  });

  Map<String, dynamic> toJson() => {
        'nombre_comun': nombreComun,
        'nombre_cientifico': nombreCientifico,
        'especie': especie,
        'descripcion': descripcion,
        'imagen': imagenBase64,
        'ubicacion': ubicacion.toJson(),
        'comportamiento': comportamiento,
        'estado_extincion': estadoExtincion,
        'estado_especimen': estadoEspecimen,
        'habitad': habitad.toJson(),
        'comentarios': comentarios?.map((c) => c.toJson()).toList() ?? [],
      };

  factory FaunaFloraData.fromJson(Map<String, dynamic> json) {
    return FaunaFloraData(
      id: json['_id'],
      nombreComun: json['nombre_comun'] ?? '',
      nombreCientifico: json['nombre_cientifico'] ?? '',
      especie: json['especie'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagenBase64: json['imagen'] ?? '',
      ubicacion: Ubicacion.fromJson(json['ubicacion']),
      comportamiento: json['comportamiento'] ?? '',
      estadoExtincion: json['estado_extincion'] ?? '',
      estadoEspecimen: json['estado_especimen'] ?? '',
      habitad: Habitat.fromJson(json['habitad']),
      comentarios: (json['comentarios'] as List?)
          ?.map((c) => Comentario.fromJson(c))
          .toList(),
    );
  }

  // Método útil para obtener el número de comentarios
  int get cantidadComentarios {
    return comentarios?.length ?? 0;
  }

  // Método útil para verificar si tiene comentarios
  bool get tieneComentarios {
    return comentarios != null && comentarios!.isNotEmpty;
  }

  @override
  String toString() {
    return 'FaunaFlora(nombre: $nombreComun, especie: $especie)';
  }

  // Método para crear una copia con cambios
  FaunaFloraData copyWith({
    String? id,
    String? nombreComun,
    String? nombreCientifico,
    String? especie,
    String? descripcion,
    String? imagenBase64,
    Ubicacion? ubicacion,
    String? comportamiento,
    String? estadoExtincion,
    String? estadoEspecimen,
    Habitat? habitad,
    List<Comentario>? comentarios,
  }) {
    return FaunaFloraData(
      id: id ?? this.id,
      nombreComun: nombreComun ?? this.nombreComun,
      nombreCientifico: nombreCientifico ?? this.nombreCientifico,
      especie: especie ?? this.especie,
      descripcion: descripcion ?? this.descripcion,
      imagenBase64: imagenBase64 ?? this.imagenBase64,
      ubicacion: ubicacion ?? this.ubicacion,
      comportamiento: comportamiento ?? this.comportamiento,
      estadoExtincion: estadoExtincion ?? this.estadoExtincion,
      estadoEspecimen: estadoEspecimen ?? this.estadoEspecimen,
      habitad: habitad ?? this.habitad,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}