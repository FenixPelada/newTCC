import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/cartao_item.dart';
import 'package:flutter_test_project/components/coluna_quadro.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/pages/page3/helpers/regras_horario.dart';
import 'package:flutter_test_project/providers/providers.dart';

class ListaCursosHorario extends ConsumerWidget {
  const ListaCursosHorario({
    super.key,
    required this.cursoSelecionado,
    required this.cargas,
    required this.aulas,
    required this.aoSelecionar,
  });

  final Curso? cursoSelecionado;
  final List<CargaCursoMateria> cargas;
  final List<Aula> aulas;
  final ValueChanged<Curso?> aoSelecionar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursosAsync = ref.watch(provedorCursos);

    return ColunaQuadro(
      flex: 3,
      titulo: 'Cursos',
      icone: Icons.school_outlined,
      child: cursosAsync.when(
        data: (cursos) {
          if (cursos.isEmpty) {
            return const DicaColunaVazia(
              mensagem: 'Nenhum curso cadastrado',
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: cursos.map((curso) {
              final estaSelecionado = cursoSelecionado?.id == curso.id;
              return CartaoItem(
                titulo: curso.nome,
                subtitulo: subtituloProgresso(curso, cargas, aulas),
                selecionado: estaSelecionado,
                aoTocar: () {
                  aoSelecionar(estaSelecionado ? null : curso);
                },
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
