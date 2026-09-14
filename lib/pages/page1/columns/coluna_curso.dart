import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/coluna_quadro.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_confirmar_exclusao.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_formulario_curso.dart';
import 'package:flutter_test_project/components/cartao_item.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/providers/providers.dart';

class ColunaCurso extends ConsumerWidget {
  const ColunaCurso({super.key});

  List<Materia> _materiasOuVazio(AsyncValue<List<Materia>> subjectsAsync) {
    return subjectsAsync.value ?? const [];
  }

  List<Sala> _salasOuVazio(AsyncValue<List<Sala>> roomsAsync) {
    return roomsAsync.value ?? const [];
  }

  Future<void> _criar(BuildContext context, WidgetRef ref) async {
    final materias = _materiasOuVazio(ref.read(provedorMaterias));
    final salas = _salasOuVazio(ref.read(provedorSalas));
    final result = await mostrarDialogoFormularioCurso(
      context,
      titulo: 'Novo curso',
      materias: materias,
      salas: salas,
    );
    if (result == null) return;

    try {
      await ref.read(provedorRepositorioCurso).adicionar(
            result.nome,
            idSala: result.idSala,
            preferenciaPeriodo: result.preferenciaPeriodo,
            cargas: result.cargas,
          );
      ref.invalidate(provedorCursos);
      ref.invalidate(provedorCargasCurso);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref,
    Curso course,
  ) async {
    final materias = _materiasOuVazio(ref.read(provedorMaterias));
    final salas = _salasOuVazio(ref.read(provedorSalas));
    final cargas =
        await ref.read(provedorRepositorioCurso).buscarCargas(course.id);
    if (!context.mounted) return;

    final result = await mostrarDialogoFormularioCurso(
      context,
      titulo: 'Editar curso',
      materias: materias,
      salas: salas,
      nomeInicial: course.nome,
      idSalaInicial: course.idSala,
      preferenciaPeriodoInicial: course.preferenciaPeriodo,
      cargasIniciais: cargas,
      idCurso: course.id,
    );
    if (result == null) return;

    try {
      await ref.read(provedorRepositorioCurso).atualizar(
            Curso(
              id: course.id,
              nome: result.nome,
              idSala: result.idSala,
              preferenciaPeriodo: result.preferenciaPeriodo,
            ),
            cargas: result.cargas,
          );
      ref.invalidate(provedorCursos);
      ref.invalidate(provedorCargasCurso);
      ref.invalidate(provedorAulas);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Curso course,
  ) async {
    final confirmed = await mostrarDialogoConfirmarExclusao(
      context,
      titulo: 'Excluir curso',
      mensagem:
          'Excluir "${course.nome}", sua carga e todas as aulas da grade?',
    );
    if (!confirmed) return;

    try {
      await ref.read(provedorRepositorioCurso).excluir(course.id);
      ref.invalidate(provedorCursos);
      ref.invalidate(provedorCargasCurso);
      ref.invalidate(provedorAulas);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  void _mostrarErro(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(provedorCursos);
    final loadsAsync = ref.watch(provedorCargasCurso);
    final roomsAsync = ref.watch(provedorSalas);
    final salasPorId = {
      for (final r in roomsAsync.value ?? const <Sala>[]) r.id: r,
    };

    return ColunaQuadro(
      titulo: 'Cursos',
      icone: Icons.school_outlined,
      acoes: [
        IconButton(
          onPressed: () => _criar(context, ref),
          tooltip: 'Adicionar curso',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: coursesAsync.when(
        data: (cursos) {
          if (cursos.isEmpty) {
            return const DicaColunaVazia(mensagem: 'Nenhum curso cadastrado');
          }

          final cargas = loadsAsync.value ?? const [];
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: cursos.map((course) {
              final courseLoads =
                  cargas.where((load) => load.idCurso == course.id);
              final totalAulas = courseLoads.fold<int>(
                0,
                (sum, load) => sum + load.quantidadeAulas,
              );
              final materiaCount = courseLoads.length;
              final room = course.idSala == null
                  ? null
                  : salasPorId[course.idSala!];

              final parts = <String>[
                course.preferenciaPeriodo.rotulo,
                if (materiaCount == 0)
                  'Sem matérias'
                else
                  '$materiaCount matérias · $totalAulas aulas',
                if (room != null) 'Sala ${room.numero}',
              ];

              return CartaoItem(
                titulo: course.nome,
                subtitulo: parts.join(' · '),
                aoEditar: () => _editar(context, ref, course),
                aoExcluir: () => _excluir(context, ref, course),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => DicaColunaVazia(mensagem: 'Erro: $e'),
      ),
    );
  }
}
