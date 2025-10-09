class Habitat {
  final String? idHabitad;
  final String nombreHabitad;
  final String? descripcionHabitat;

  Habitat({
    this.idHabitad,
    required this.nombreHabitad,
    this.descripcionHabitat,
  });

  Map<String, dynamic> toJson() => {
        'id_habitad': idHabitad,
        'nombre_habitad': nombreHabitad,
        'descripcion_habitat': descripcionHabitat,
      };

  factory Habitat.fromJson(Map<String, dynamic> json) {
    return Habitat(
      idHabitad: json['id_habitad'],
      nombreHabitad: json['nombre_habitad'] ?? '',
      descripcionHabitat: json['descripcion_habitat'],
    );
  }

  @override
  String toString() {
    return 'Habitat(nombre: $nombreHabitad)';
  }
}
