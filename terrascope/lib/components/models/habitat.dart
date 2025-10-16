class Habitat {
  final String idHabitat;
  final String nombreHabitat;
  final String descripcionHabitat;

  Habitat({
    required this.idHabitat,
    required this.nombreHabitat,
    required this.descripcionHabitat,
  });

  Map<String, dynamic> toJson() => {
        'id_habitat': idHabitat,
        'nombre_habitat': nombreHabitat,
        'descripcion_habitat': descripcionHabitat,
      };

  factory Habitat.fromJson(Map<String, dynamic> json) {
    return Habitat(
      idHabitat: json['id_habitat'] ?? '',  // ← Valor por defecto si es null
      nombreHabitat: json['nombre_habitat'] ?? 'Sin nombre',  // ← Valor por defecto
      descripcionHabitat: json['descripcion_habitat'] ?? 'Sin descripción',  // ← Valor por defecto
    );
  }

  @override
  String toString() => 'Habitat(nombre: $nombreHabitat)';
}