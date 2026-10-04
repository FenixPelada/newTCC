enum TipoSala {
  salaAula,
  laboratorioInformatica;

  static TipoSala fromDb(String? value) => switch (value) {
    'laboratorio_informatica' => TipoSala.laboratorioInformatica,
    _ => TipoSala.salaAula,
  };

  String toDb() => switch (this) {
    TipoSala.salaAula => 'sala_aula',
    TipoSala.laboratorioInformatica => 'laboratorio_informatica',
  };

  String get rotulo => switch (this) {
    TipoSala.salaAula => 'Sala de aula',
    TipoSala.laboratorioInformatica => 'Laboratório de informática',
  };
}

class SalaDuplicada implements Exception {
  const SalaDuplicada();
}

class Sala {
  Sala({
    required this.id,
    required this.numero,
    this.tipo = TipoSala.salaAula,
  });

  final String id;
  final int numero;
  final TipoSala tipo;

  String get rotulo => '${tipo.rotulo} $numero';

  factory Sala.fromJson(Map<String, dynamic> json) => Sala(
    id: json['id'].toString(),
    numero: (json['numero'] as num).toInt(),
    tipo: TipoSala.fromDb(json['tipo'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero': numero,
    'tipo': tipo.toDb(),
  };

  Map<String, dynamic> toInsertJson() => {
    'numero': numero,
    'tipo': tipo.toDb(),
  };
}
