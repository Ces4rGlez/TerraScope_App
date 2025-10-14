class Comentario {
  final String? idUsuario;
  final String nombreUsuario;
  final String comentario;
  final DateTime fecha;

  Comentario({
    this.idUsuario,
    required this.nombreUsuario,
    required this.comentario,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
    'id_usuario': idUsuario,
    'nombre_usuario': nombreUsuario,
    'comentario': comentario,
    'fecha': fecha.toIso8601String(),
  };

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'] ?? '',
      comentario: json['comentario'] ?? '',
      fecha: DateTime.parse(json['fecha']),
    );
  }

  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  String toString() {
    return 'Comentario(usuario: $nombreUsuario, fecha: $fechaFormateada)';
  }
}
