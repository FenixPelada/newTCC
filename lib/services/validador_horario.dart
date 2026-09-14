import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/curso/preferencia_periodo.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/indisponibilidade_professor.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/model/materia/materia.dart';

class ValidacaoHorario {
  const ValidacaoHorario({required this.problemas});

  final List<String> problemas;

  bool get ok => problemas.isEmpty;
}

/// Valida o horário de uma turma e conflitos globais que a envolvem.
class ValidadorHorario {
  const ValidadorHorario();

  ValidacaoHorario validarCurso({
    required String idCurso,
    required List<Aula> todasAulas,
    required List<Curso> cursos,
    required List<CargaCursoMateria> cargas,
    required List<Professor> professores,
    required List<Materia> materias,
    required List<Sala> salas,
    required List<IndisponibilidadeProfessor> indisponibilidades,
  }) {
    final problemas = <String>[];
    final course = cursos.where((c) => c.id == idCurso).firstOrNull;
    if (course == null) return const ValidacaoHorario(problemas: []);

    final courseById = {for (final c in cursos) c.id: c};
    final professorById = {for (final p in professores) p.id: p.nome};
    final subjectById = {for (final s in materias) s.id: s.nome};
    final roomById = {for (final r in salas) r.id: r};

    final courseAulas = todasAulas.where((a) => a.idCurso == idCurso).toList();

    for (final load in cargas.where((l) => l.idCurso == idCurso)) {
      final nomeMateria = subjectById[load.idMateria] ?? 'Matéria';
      final scheduled = courseAulas
          .where((a) => a.idMateria == load.idMateria)
          .length;
      if (scheduled > load.quantidadeAulas) {
        problemas.add('Aulas de $nomeMateria demais');
      } else if (scheduled < load.quantidadeAulas) {
        final missing = load.quantidadeAulas - scheduled;
        problemas.add(
          'Faltam $missing aula(s) de $nomeMateria '
          '($scheduled/${load.quantidadeAulas})',
        );
      }
    }

    for (final aula in courseAulas) {
      final celula = aula.celula;
      final nomeProfessor =
          professorById[aula.idProfessor] ?? 'Professor ${aula.idProfessor}';

      if (_estaIndisponivel(indisponibilidades, aula.idProfessor, celula)) {
        problemas.add(
          '$nomeProfessor no horário errado '
          '(${_rotuloCelula(celula)})',
        );
      }

      if (course.preferenciaPeriodo != PreferenciaPeriodo.contraturno) {
        final isMorning = celula.indicePeriodo < GradeHoraria.quantidadePeriodosManha;
        final wrongPeriod = switch (course.preferenciaPeriodo) {
          PreferenciaPeriodo.manha => !isMorning,
          PreferenciaPeriodo.tarde => isMorning,
          PreferenciaPeriodo.contraturno => false,
        };
        if (wrongPeriod) {
          problemas.add(
            'Aula fora do período da turma (${_rotuloCelula(celula)})',
          );
        }
      }

      for (final other in todasAulas) {
        if (other.id == aula.id) continue;
        if (other.indiceDia != aula.indiceDia ||
            other.indicePeriodo != aula.indicePeriodo) {
          continue;
        }

        if (other.idProfessor == aula.idProfessor &&
            other.idCurso != aula.idCurso) {
          final otherCourse =
              courseById[other.idCurso]?.nome ?? 'outro curso';
          problemas.add(
            '$nomeProfessor já está dando aula no curso $otherCourse '
            '(${_rotuloCelula(celula)})',
          );
        }

        final idSala = aula.idSala;
        if (idSala != null &&
            other.idSala == idSala &&
            other.idCurso != aula.idCurso) {
          final room = roomById[idSala];
          final roomLabel =
              room == null ? 'Sala' : 'Sala ${room.numero}';
          final otherCourse =
              courseById[other.idCurso]?.nome ?? 'outra turma';
          problemas.add(
            '$roomLabel ocupada por $otherCourse (${_rotuloCelula(celula)})',
          );
        }
      }
    }

    return ValidacaoHorario(problemas: _deduplicar(problemas));
  }

  bool _estaIndisponivel(
    List<IndisponibilidadeProfessor> linhas,
    String idProfessor,
    CelulaGrade celula,
  ) {
    return linhas.any(
      (u) =>
          u.idProfessor == idProfessor &&
          u.indiceDia == celula.indiceDia &&
          u.indicePeriodo == celula.indicePeriodo,
    );
  }

  String _rotuloCelula(CelulaGrade celula) {
    final day = GradeHoraria.dias[celula.indiceDia];
    final period = GradeHoraria.periodos[celula.indicePeriodo];
    return '$day $period';
  }

  List<String> _deduplicar(List<String> items) {
    final seen = <String>{};
    final out = <String>[];
    for (final item in items) {
      if (seen.add(item)) out.add(item);
    }
    return out;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
