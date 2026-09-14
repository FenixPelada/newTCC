import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_confirmar_exclusao.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_formulario_aula.dart';
import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/model/professor/indisponibilidade_professor.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_materia.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/pages/page3/helpers/regras_horario.dart';
import 'package:flutter_test_project/providers/providers.dart';
import 'package:flutter_test_project/services/gerador_horario.dart';

/// Ações de horário (gerar, limpar, editar aula) — sem widgets de layout.
class AcoesHorario {
  AcoesHorario(this.ref);

  final WidgetRef ref;

  Future<String?> limparCurso({
    required BuildContext context,
    required Curso curso,
  }) async {
    final confirmado = await mostrarDialogoConfirmarExclusao(
      context,
      titulo: 'Limpar grade',
      mensagem:
          'Remover todas as aulas de "${curso.nome}"? Esta ação não desfaz.',
    );
    if (!confirmado) return null;

    await ref.read(provedorRepositorioAula).excluirPorCurso(curso.id);
    ref.invalidate(provedorAulas);
    return 'Grade de "${curso.nome}" limpa.';
  }

  Future<String?> gerarTodos({
    required BuildContext context,
    required List<Curso> cursos,
    required List<CargaCursoMateria> cargas,
    required List<Professor> professores,
    required List<ProfessorMateria> ligacoes,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    required List<Materia> materias,
  }) async {
    final confirmado = await mostrarDialogoConfirmarExclusao(
      context,
      titulo: 'Gerar horários',
      mensagem:
          'Regenerar os horários de todas as turmas? '
          'Isso apaga os horários atuais e recria com base nas '
          'configurações da Página 1.',
      rotuloConfirmar: 'Gerar',
    );
    if (!confirmado) return null;

    final repo = ref.read(provedorRepositorioAula);
    await repo.excluirTodas();

    final resultado = const GeradorHorario().gerarTodos(
      cursos: cursos,
      cargas: cargas,
      professores: professores,
      ligacoes: ligacoes,
      indisponibilidades: indisponibilidades,
      nomesMaterias: {for (final m in materias) m.id: m.nome},
      nomesCursos: {for (final c in cursos) c.id: c.nome},
    );

    for (final aula in resultado.novasAulas) {
      await repo.adicionar(aula);
    }
    ref.invalidate(provedorAulas);

    if (resultado.completo) {
      return 'Horários gerados: ${resultado.novasAulas.length} aula(s) alocadas.';
    }
    if (resultado.novasAulas.isEmpty && resultado.falhas.isNotEmpty) {
      return 'Não foi possível gerar: ${resultado.falhas.first}';
    }
    return 'Parcial: ${resultado.novasAulas.length} aula(s). '
        '${resultado.falhas.take(3).join(' ')}';
  }

  Future<String?> aoTocarCelula({
    required BuildContext context,
    required CelulaGrade celula,
    required Curso curso,
    required Aula? existente,
    required List<Materia> materiasCurso,
    required List<Materia> todasMaterias,
    required List<Professor> professores,
    required List<ProfessorMateria> ligacoes,
    required List<Aula> todasAulas,
    required List<CargaCursoMateria> cargas,
    required List<IndisponibilidadeProfessor> indisponibilidades,
    required List<Sala> salas,
  }) async {
    final rotuloDia = GradeHoraria.dias[celula.indiceDia];
    final rotuloPeriodo = GradeHoraria.periodos[celula.indicePeriodo];
    final titulo = existente == null
        ? 'Nova aula — $rotuloDia $rotuloPeriodo'
        : 'Editar aula — $rotuloDia $rotuloPeriodo';

    final resultado = await mostrarDialogoFormularioAula(
      context,
      titulo: titulo,
      materias: materiasParaDialogoAula(
        materiasCurso: materiasCurso,
        todasMaterias: todasMaterias,
        existente: existente,
      ),
      salas: salas,
      professoresDaMateria: (idMateria) => professoresParaDialogoAula(
        idMateria: idMateria,
        celula: celula,
        professores: professores,
        ligacoes: ligacoes,
        indisponibilidades: indisponibilidades,
        todasAulas: todasAulas,
        existente: existente,
      ),
      idMateriaInicial: existente?.idMateria,
      idProfessorInicial: existente?.idProfessor,
      idSalaInicial: existente?.idSala ?? curso.idSala,
      permitirExcluir: existente != null,
      mensagemExclusao: existente == null
          ? null
          : 'Excluir a aula de $rotuloDia $rotuloPeriodo?',
    );

    if (resultado == null) return null;

    if (resultado is ExclusaoFormularioAula) {
      if (existente == null) return null;
      await ref.read(provedorRepositorioAula).excluir(existente.id);
      ref.invalidate(provedorAulas);
      return null;
    }

    if (resultado is! ResultadoFormularioAula) return null;

    final erro = validarSalvarAula(
      curso: curso,
      celula: celula,
      idMateria: resultado.idMateria,
      idProfessor: resultado.idProfessor,
      idSala: resultado.idSala,
      existente: existente,
      cargas: cargas,
      todasAulas: todasAulas,
      ligacoes: ligacoes,
      indisponibilidades: indisponibilidades,
    );
    if (erro != null) return erro;

    final aula = Aula(
      id: existente?.id ?? '0',
      idCurso: curso.id,
      indiceDia: celula.indiceDia,
      indicePeriodo: celula.indicePeriodo,
      idMateria: resultado.idMateria,
      idProfessor: resultado.idProfessor,
      idSala: resultado.idSala,
    );

    if (existente == null) {
      await ref.read(provedorRepositorioAula).adicionar(aula);
    } else {
      await ref.read(provedorRepositorioAula).atualizar(aula);
    }
    ref.invalidate(provedorAulas);
    return null;
  }
}
