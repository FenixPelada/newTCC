import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/model/professor/indisponibilidade_professor.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_materia.dart';
import 'package:flutter_test_project/model/sala/sala.dart';

Map<String, Materia> materiaPorId(List<Materia> materias) => {
      for (final m in materias) m.id: m,
    };

Map<String, Professor> professorPorId(List<Professor> professores) => {
      for (final p in professores) p.id: p,
    };

Map<String, Sala> salaPorId(List<Sala> salas) => {
      for (final s in salas) s.id: s,
    };

List<Materia> materiasDoCurso(
  String idCurso,
  List<CargaCursoMateria> cargas,
  List<Materia> materias,
) {
  final ids = cargas
      .where((l) => l.idCurso == idCurso)
      .map((l) => l.idMateria)
      .toSet();
  return materias.where((m) => ids.contains(m.id)).toList();
}

bool estaIndisponivel(
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

List<Professor> professoresDaMateriaNaCelula({
  required String idMateria,
  required CelulaGrade celula,
  required List<Professor> professores,
  required List<ProfessorMateria> ligacoes,
  required List<IndisponibilidadeProfessor> indisponibilidades,
  required List<Aula> todasAulas,
  String? idAulaExcluida,
}) {
  final idsLigados = ligacoes
      .where((l) => l.idMateria == idMateria)
      .map((l) => l.idProfessor)
      .toSet();

  return professores.where((p) {
    if (!idsLigados.contains(p.id)) return false;
    if (estaIndisponivel(indisponibilidades, p.id, celula)) return false;
    final ocupado = todasAulas.any(
      (a) =>
          a.id != idAulaExcluida &&
          a.idProfessor == p.id &&
          a.indiceDia == celula.indiceDia &&
          a.indicePeriodo == celula.indicePeriodo,
    );
    return !ocupado;
  }).toList();
}

int quantidadeAgendada(
  List<Aula> aulas,
  String idCurso,
  String idMateria, {
  String? idAulaExcluida,
}) {
  return aulas
      .where(
        (a) =>
            a.idCurso == idCurso &&
            a.idMateria == idMateria &&
            a.id != idAulaExcluida,
      )
      .length;
}

int? cargaMaxima(
  List<CargaCursoMateria> cargas,
  String idCurso,
  String idMateria,
) {
  for (final carga in cargas) {
    if (carga.idCurso == idCurso && carga.idMateria == idMateria) {
      return carga.quantidadeAulas;
    }
  }
  return null;
}

String subtituloProgresso(
  Curso curso,
  List<CargaCursoMateria> cargas,
  List<Aula> aulas,
) {
  final cargasDoCurso = cargas.where((l) => l.idCurso == curso.id).toList();
  if (cargasDoCurso.isEmpty) return 'Sem carga definida';

  final necessario =
      cargasDoCurso.fold<int>(0, (s, l) => s + l.quantidadeAulas);
  final alocado = aulas.where((a) => a.idCurso == curso.id).length;
  return '$alocado/$necessario aulas alocadas';
}

/// Professores disponíveis + professor atual (mesmo bloqueado) ao editar.
List<Professor> professoresParaDialogoAula({
  required String idMateria,
  required CelulaGrade celula,
  required List<Professor> professores,
  required List<ProfessorMateria> ligacoes,
  required List<IndisponibilidadeProfessor> indisponibilidades,
  required List<Aula> todasAulas,
  Aula? existente,
}) {
  final disponiveis = professoresDaMateriaNaCelula(
    idMateria: idMateria,
    celula: celula,
    professores: professores,
    ligacoes: ligacoes,
    indisponibilidades: indisponibilidades,
    todasAulas: todasAulas,
    idAulaExcluida: existente?.id,
  );

  if (existente != null &&
      existente.idMateria == idMateria &&
      !disponiveis.any((p) => p.id == existente.idProfessor)) {
    final atual = professores.where((p) => p.id == existente.idProfessor);
    if (atual.isNotEmpty) {
      return [...disponiveis, atual.first];
    }
  }
  return disponiveis;
}

List<Materia> materiasParaDialogoAula({
  required List<Materia> materiasCurso,
  required List<Materia> todasMaterias,
  Aula? existente,
}) {
  final lista = List<Materia>.from(materiasCurso);
  if (existente != null &&
      !lista.any((m) => m.id == existente.idMateria)) {
    final orfao = todasMaterias.where((m) => m.id == existente.idMateria);
    if (orfao.isNotEmpty) {
      lista.add(orfao.first);
    }
  }
  return lista;
}

/// Retorna mensagem de erro ou null se a aula pode ser salva.
String? validarSalvarAula({
  required Curso curso,
  required CelulaGrade celula,
  required String idMateria,
  required String idProfessor,
  required String? idSala,
  required Aula? existente,
  required List<CargaCursoMateria> cargas,
  required List<Aula> todasAulas,
  required List<ProfessorMateria> ligacoes,
  required List<IndisponibilidadeProfessor> indisponibilidades,
}) {
  final maximo = cargaMaxima(cargas, curso.id, idMateria);
  if (maximo == null) {
    return 'Matéria não pertence à carga deste curso.';
  }

  final jaAgendada = quantidadeAgendada(
    todasAulas,
    curso.id,
    idMateria,
    idAulaExcluida: existente?.id,
  );
  if (jaAgendada >= maximo) {
    return 'Carga completa para esta matéria ($maximo aula(s)).';
  }

  final vinculado = ligacoes.any(
    (l) => l.idProfessor == idProfessor && l.idMateria == idMateria,
  );
  if (!vinculado) {
    return 'Este professor não está vinculado a esta matéria.';
  }

  if (estaIndisponivel(indisponibilidades, idProfessor, celula)) {
    return 'Professor indisponível neste horário (Página 2).';
  }

  final professorOcupado = todasAulas.any(
    (a) =>
        a.id != existente?.id &&
        a.idProfessor == idProfessor &&
        a.indiceDia == celula.indiceDia &&
        a.indicePeriodo == celula.indicePeriodo,
  );
  if (professorOcupado) {
    return 'Este professor já está alocado neste horário.';
  }

  if (idSala != null) {
    final salaOcupada = todasAulas.any(
      (a) =>
          a.id != existente?.id &&
          a.idSala == idSala &&
          a.indiceDia == celula.indiceDia &&
          a.indicePeriodo == celula.indicePeriodo,
    );
    if (salaOcupada) {
      return 'Esta sala já está ocupada neste horário.';
    }
  }

  return null;
}
