class Validacion{
  final String estado;
  final int votosComunidad;
  final int requeridosComunidad;
  final List<String> usuariosValidadores;
  final bool validadoPorExperto;

  Validacion({
   this.estado = 'pendiente',
     this.votosComunidad = 0,
     this.requeridosComunidad = 5,
     this.usuariosValidadores = const[],
   this.validadoPorExperto = false,
  });

  factory Validacion.fromJson(Map<String, dynamic> json) {
    return Validacion(
      estado: json['estado'] ?? 'pendiente',
      votosComunidad: json['votos_comunidad'] ?? 0,
      requeridosComunidad: json['requeridos_comunidad'] ?? 5,
      usuariosValidadores: (json['usuarios_validadores'] as List?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      validadoPorExperto: json['validado_por_experto'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estado': estado,
      'votos_comunidad': votosComunidad,
      'requeridos_comunidad': requeridosComunidad,
      'usuarios_validadores': usuariosValidadores,
      'validado_por_experto': validadoPorExperto,
    };
  }

  // Métodos útiles
  bool get esPendiente => estado == 'pendiente';
  bool get esValidadoComunidad => estado == 'validado_comunidad';
  bool get esValidadoExperto => estado == 'validado_experto';
  
  int get votosRestantes => requeridosComunidad - votosComunidad;
  bool get alcanzaVotosComunidad => votosComunidad >= requeridosComunidad;

  @override
  String toString() {
    return 'Validacion(estado: $estado, votos: $votosComunidad/$requeridosComunidad, experto: $validadoPorExperto)';
  }
}