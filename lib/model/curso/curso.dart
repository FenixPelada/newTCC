import 'package:flutter_test_project/model/curso/preferencia_periodo.dart';

class Curso {
  Curso({
    required this.id,
    required this.nome,
    this.idSala,
    this.preferenciaPeriodo = PreferenciaPeriodo.manha,
    this.turnoCompartilhado = false,
  });

  final String id;
  final String nome;

  /// Sala padrão do curso (opcional).
  final String? idSala;

  /// Manhã, tarde ou contraturno (manhã → tarde → 2 períodos de contraturno).
  final PreferenciaPeriodo preferenciaPeriodo;

  /// Se true, a turma pode ter 2 aulas no mesmo horário (2 grupos).
  final bool turnoCompartilhado;

  factory Curso.fromJson(Map<String, dynamic> json) => Curso(
        id: json['id'].toString(),
        nome: json['nome'] as String,
        idSala: json['id_sala']?.toString(),
        preferenciaPeriodo: PreferenciaPeriodo.fromDb(
          json['periodo_preferencia'] as String?,
        ),
        turnoCompartilhado: json['turno_compartilhado'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        if (idSala != null) 'id_sala': int.parse(idSala!),
        'periodo_preferencia': preferenciaPeriodo.toDb(),
        'turno_compartilhado': turnoCompartilhado,
      };

  Map<String, dynamic> toInsertJson() => {
        'nome': nome,
        if (idSala != null) 'id_sala': int.parse(idSala!),
        'periodo_preferencia': preferenciaPeriodo.toDb(),
        'turno_compartilhado': turnoCompartilhado,
      };
}
