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
