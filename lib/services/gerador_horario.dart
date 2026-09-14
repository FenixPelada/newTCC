import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/curso/preferencia_periodo.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_materia.dart';
import 'package:flutter_test_project/model/professor/indisponibilidade_professor.dart';

class ResultadoGeracao {
  const ResultadoGeracao({
    required this.novasAulas,
    required this.totalAlocado,
    required this.totalNecessario,
    required this.falhas,
  });

  final List<Aula> novasAulas;
  final int totalAlocado;
  final int totalNecessario;
  final List<String> falhas;

  bool get completo => falhas.isEmpty && totalAlocado >= totalNecessario;
}

class ResultadoGeracaoCompleta {
  const ResultadoGeracaoCompleta({
    required this.novasAulas,
    required this.falhas,
  });

  final List<Aula> novasAulas;
  final List<String> falhas;

  bool get completo => falhas.isEmpty;
}

/// Coloca aulas em blocos de 1 ou 2, respeitando turno, sala e indisponibilidade.
class GeradorHorario {
  const GeradorHorario();

  ResultadoGeracaoCompleta gerarTodos({
    required List<Curso> cursos,
    required List<CargaCursoMateria> cargas,
    required List<Professor> professores,
    required List<ProfessorMateria> ligacoes,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    Map<String, String> nomesMaterias = const {},
    Map<String, String> nomesCursos = const {},
  }) {
    final trabalhando = <Aula>[];
    final novasAulas = <Aula>[];
    final falhas = <String>[];

    final ordenados = List<Curso>.from(cursos)
      ..sort((a, b) {
        final cargaA = _totalNecessario(cargas, a.id);
        final cargaB = _totalNecessario(cargas, b.id);
        return cargaB.compareTo(cargaA);
      });

    for (final curso in ordenados) {
      final resultado = gerar(
        curso: curso,
        cargas: cargas,
        professores: professores,
        ligacoes: ligacoes,
        indisponibilidades: indisponibilidades,
        aulasExistentes: trabalhando,
        nomesMaterias: nomesMaterias,
      );
      trabalhando.addAll(resultado.novasAulas);
      novasAulas.addAll(resultado.novasAulas);
      final rotuloCurso = nomesCursos[curso.id] ?? curso.nome;
      falhas.addAll(
        resultado.falhas.map((f) => '$rotuloCurso: $f'),
      );
    }

    return ResultadoGeracaoCompleta(
      novasAulas: novasAulas,
      falhas: falhas,
    );
  }

  ResultadoGeracao gerar({
    required Curso curso,
    required List<CargaCursoMateria> cargas,
    required List<Professor> professores,
    required List<ProfessorMateria> ligacoes,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    required List<Aula> aulasExistentes,
    Map<String, String> nomesMaterias = const {},
  }) {
    final idCurso = curso.id;
    final cargasCurso =
        cargas.where((l) => l.idCurso == idCurso).toList();
    final totalNecessario =
        cargasCurso.fold<int>(0, (soma, l) => soma + l.quantidadeAulas);

    if (cargasCurso.isEmpty) {
      return const ResultadoGeracao(
        novasAulas: [],
        totalAlocado: 0,
        totalNecessario: 0,
        falhas: ['Curso sem carga de matérias definida.'],
      );
    }

    final trabalhando = List<Aula>.from(aulasExistentes);
    final novasAulas = <Aula>[];
    final falhas = <String>[];

    cargasCurso.sort((a, b) {
      final contagemA =
          ligacoes.where((l) => l.idMateria == a.idMateria).length;
      final contagemB =
          ligacoes.where((l) => l.idMateria == b.idMateria).length;
      return contagemA.compareTo(contagemB);
    });

    String rotulo(String idMateria) =>
        nomesMaterias[idMateria] ?? 'matéria $idMateria';

    for (final carga in cargasCurso) {
      final jaAlocado = trabalhando
          .where(
            (a) => a.idCurso == idCurso && a.idMateria == carga.idMateria,
          )
          .length;
      var restante = carga.quantidadeAulas - jaAlocado;
      if (restante <= 0) continue;

      final professoresMateria = professores
          .where(
            (p) => ligacoes.any(
              (l) => l.idProfessor == p.id && l.idMateria == carga.idMateria,
            ),
          )
          .toList();

      if (professoresMateria.isEmpty) {
        falhas.add(
          '${rotulo(carga.idMateria)}: nenhum professor vinculado '
          '($restante aula(s) faltando).',
        );
        continue;
      }

      final blocos = _blocosPara(restante, carga.tamanhoBloco);
      final fasesPeriodo = _fasesPeriodo(curso.preferenciaPeriodo);

      for (final tamanhoBloco in blocos) {
        var alocado = false;

        for (final faixaPeriodos in fasesPeriodo) {
          if (alocado) break;

          for (var dia = 0;
              dia < GradeHoraria.dias.length && !alocado;
              dia++) {
            for (final periodoInicio
                in _periodosInicio(faixaPeriodos, tamanhoBloco)) {
              if (_tentarColocarBloco(
                idCurso: idCurso,
                idMateria: carga.idMateria,
                dia: dia,
                periodoInicio: periodoInicio,
                tamanhoBloco: tamanhoBloco,
                idSala: curso.idSala,
                professoresMateria: professoresMateria,
                indisponibilidades: indisponibilidades,
                trabalhando: trabalhando,
                novasAulas: novasAulas,
              )) {
                alocado = true;
                restante -= tamanhoBloco;
                break;
              }
            }
          }
        }

        if (!alocado) {
          falhas.add(
            'Não coube bloco de $tamanhoBloco aula(s) de '
            '${rotulo(carga.idMateria)}.',
          );
        }
      }

      if (restante > 0) {
        falhas.add(
          'Faltam $restante aula(s) de ${rotulo(carga.idMateria)}.',
        );
      }
    }

    final totalAlocado =
        aulasExistentes.where((a) => a.idCurso == idCurso).length +
            novasAulas.length;

    return ResultadoGeracao(
      novasAulas: novasAulas,
      totalAlocado: totalAlocado,
      totalNecessario: totalNecessario,
      falhas: falhas,
    );
  }

  int _totalNecessario(List<CargaCursoMateria> cargas, String idCurso) {
    return cargas
        .where((l) => l.idCurso == idCurso)
        .fold<int>(0, (soma, l) => soma + l.quantidadeAulas);
  }

  List<int> _blocosPara(int total, int blocoPreferido) {
    final tamanho = blocoPreferido == 2 ? 2 : 1;
    final blocos = <int>[];
    var restante = total;
    while (restante > 0) {
      if (tamanho == 2 && restante >= 2) {
        blocos.add(2);
        restante -= 2;
      } else {
        blocos.add(1);
        restante -= 1;
      }
    }
    return blocos;
  }

  List<List<int>> _fasesPeriodo(PreferenciaPeriodo preferencia) {
    const manha = [0, 1, 2, 3, 4, 5];
    const tarde = [6, 7, 8, 9, 10, 11];
    return switch (preferencia) {
      PreferenciaPeriodo.manha => [manha],
      PreferenciaPeriodo.tarde => [tarde],
      PreferenciaPeriodo.contraturno => [manha, tarde],
    };
  }

  Iterable<int> _periodosInicio(
    List<int> faixaPeriodos,
    int tamanhoBloco,
  ) sync* {
    for (var i = 0; i <= faixaPeriodos.length - tamanhoBloco; i++) {
      yield faixaPeriodos[i];
    }
  }

  bool _tentarColocarBloco({
    required String idCurso,
    required String idMateria,
    required int dia,
    required int periodoInicio,
    required int tamanhoBloco,
    required String? idSala,
    required List<Professor> professoresMateria,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    required List<Aula> trabalhando,
    required List<Aula> novasAulas,
  }) {
    Professor? escolhido;
    for (final professor in professoresMateria) {
      if (_blocoCabe(
        idCurso: idCurso,
        idProfessor: professor.id,
        idMateria: idMateria,
        dia: dia,
        periodoInicio: periodoInicio,
        tamanhoBloco: tamanhoBloco,
        idSala: idSala,
        indisponibilidades: indisponibilidades,
        trabalhando: trabalhando,
      )) {
        escolhido = professor;
        break;
      }
    }
    if (escolhido == null) return false;

    for (var deslocamento = 0; deslocamento < tamanhoBloco; deslocamento++) {
      final aula = Aula(
        id: 'pending',
        idCurso: idCurso,
        indiceDia: dia,
        indicePeriodo: periodoInicio + deslocamento,
        idMateria: idMateria,
        idProfessor: escolhido.id,
        idSala: idSala,
      );
      trabalhando.add(aula);
      novasAulas.add(aula);
    }
    return true;
  }

  bool _blocoCabe({
    required String idCurso,
    required String idProfessor,
    required String idMateria,
    required int dia,
    required int periodoInicio,
    required int tamanhoBloco,
    required String? idSala,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    required List<Aula> trabalhando,
  }) {
    // Gerador: no máximo um bloco da mesma matéria por dia (manual pode repetir).
    if (trabalhando.any(
      (a) =>
          a.idCurso == idCurso &&
          a.idMateria == idMateria &&
          a.indiceDia == dia,
    )) {
      return false;
    }

    final eManha = periodoInicio < GradeHoraria.quantidadePeriodosManha;
    for (var deslocamento = 0; deslocamento < tamanhoBloco; deslocamento++) {
      final periodo = periodoInicio + deslocamento;
      final periodoEManha = periodo < GradeHoraria.quantidadePeriodosManha;
      if (periodoEManha != eManha) return false;

      final celula = CelulaGrade(indiceDia: dia, indicePeriodo: periodo);

      if (trabalhando.any(
        (a) =>
            a.idCurso == idCurso &&
            a.indiceDia == dia &&
            a.indicePeriodo == periodo,
      )) {
        return false;
      }

      if (trabalhando.any(
        (a) =>
            a.idProfessor == idProfessor &&
            a.indiceDia == dia &&
            a.indicePeriodo == periodo,
      )) {
        return false;
      }

      if (idSala != null &&
          trabalhando.any(
            (a) =>
                a.idSala == idSala &&
                a.indiceDia == dia &&
                a.indicePeriodo == periodo,
          )) {
        return false;
      }

      if (_estaIndisponivel(indisponibilidades, idProfessor, celula)) {
        return false;
      }
    }
    return true;
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
}
