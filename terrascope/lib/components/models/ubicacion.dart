class Ubicacion {
  final double latitud;
  final double longitud;

  Ubicacion({
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> toJson() => {
        'latitud': latitud,
        'longitud': longitud,
      };

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
    );
  }

  @override
  String toString() {
    return 'Ubicacion(lat: ${latitud.toStringAsFixed(6)}, lng: ${longitud.toStringAsFixed(6)})';
  }
}
