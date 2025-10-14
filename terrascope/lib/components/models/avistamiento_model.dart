class Avistamiento {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final String especie;
  final String descripcion;
  final String imagen;
  final Ubicacion ubicacion;
  final String comportamiento;
  final String estadoExtincion;
  final String estadoEspecimen;
  final Habitad habitad;
  final List<Comentario> comentarios;
  final String tipo;
  final String nombreUsuario;

  Avistamiento({
    required this.id,
    required this.nombreComun,
    required this.nombreCientifico,
    required this.especie,
    required this.descripcion,
    required this.imagen,
    required this.ubicacion,
    required this.comportamiento,
    required this.estadoExtincion,
    required this.estadoEspecimen,
    required this.habitad,
    required this.comentarios,
    required this.tipo,
    required this.nombreUsuario,
  });

  factory Avistamiento.fromJson(Map<String, dynamic> json) {
    return Avistamiento(
      id: json['_id'] ?? '',
      nombreComun: json['nombre_comun'] ?? '',
      nombreCientifico: json['nombre_cientifico'] ?? '',
      especie: json['especie'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'] ?? '',
      tipo: json['tipo'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      ubicacion: Ubicacion.fromJson(json['ubicacion'] ?? {}),
      comportamiento: json['comportamiento'] ?? '',
      estadoExtincion: json['estado_extincion'] ?? '',
      estadoEspecimen: json['estado_especimen'] ?? '',
      habitad: Habitad.fromJson(json['habitad'] ?? {}),
      comentarios:
          (json['comentarios'] as List?)
              ?.map((c) => Comentario.fromJson(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nombre_comun': nombreComun,
      'nombre_cientifico': nombreCientifico,
      'especie': especie,
      'descripcion': descripcion,
      'imagen': imagen,
      'tipo': tipo,
      'nombre_usuario': nombreUsuario,
      'ubicacion': ubicacion.toJson(),
      'comportamiento': comportamiento,
      'estado_extincion': estadoExtincion,
      'estado_especimen': estadoEspecimen,
      'habitad': habitad.toJson(),
      'comentarios': comentarios.map((c) => c.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Avistamiento(id: $id, nombre: $nombreComun, especie: $especie)';
  }
}

class Ubicacion {
  final double latitud;
  final double longitud;

  Ubicacion({required this.latitud, required this.longitud});

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      latitud: (json['latitud'] ?? 0).toDouble(),
      longitud: (json['longitud'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitud': latitud, 'longitud': longitud};
  }

  @override
  String toString() => 'Ubicacion(lat: $latitud, lng: $longitud)';
}

class Habitad {
  final String idHabitad;
  final String nombreHabitad;
  final String descripcionHabitat;

  Habitad({
    required this.idHabitad,
    required this.nombreHabitad,
    required this.descripcionHabitat,
  });

  factory Habitad.fromJson(Map<String, dynamic> json) {
    return Habitad(
      idHabitad: json['id_habitad'] ?? '',
      nombreHabitad: json['nombre_habitad'] ?? '',
      descripcionHabitat: json['descripcion_habitat'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_habitad': idHabitad,
      'nombre_habitad': nombreHabitad,
      'descripcion_habitat': descripcionHabitat,
    };
  }

  @override
  String toString() => 'Habitad(nombre: $nombreHabitad)';
}

class Comentario {
  final String idUsuario;
  final String nombreUsuario;
  final String comentario;
  final DateTime fecha;

  Comentario({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.comentario,
    required this.fecha,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      idUsuario: json['id_usuario'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      comentario: json['comentario'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre_usuario': nombreUsuario,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }

  @override
  String toString() => 'Comentario($nombreUsuario: $comentario)';
}

class ZonaFrecuente {
  final double lat;
  final double lng;
  final String especie;
  final int count;

  ZonaFrecuente({
    required this.lat,
    required this.lng,
    required this.especie,
    required this.count,
  });

  factory ZonaFrecuente.fromJson(Map<String, dynamic> json) {
    return ZonaFrecuente(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      especie: json['especie'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'especie': especie, 'count': count};
  }

  @override
  String toString() => 'ZonaFrecuente($especie: $count avistamientos)';
}
