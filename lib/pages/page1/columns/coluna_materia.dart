import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/coluna_quadro.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_confirmar_exclusao.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_nome.dart';
import 'package:flutter_test_project/components/cartao_item.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/providers/providers.dart';

class ColunaMateria extends ConsumerWidget {
  const ColunaMateria({super.key});

  Future<void> _criar(BuildContext context, WidgetRef ref) async {
    final nome = await mostrarDialogoNome(
      context,
      titulo: 'Nova matéria',
    );
    if (nome == null) return;

    try {
      await ref.read(provedorRepositorioMateria).adicionar(nome);
      ref.invalidate(provedorMaterias);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref,
    Materia subject,
  ) async {
    final nome = await mostrarDialogoNome(
      context,
      titulo: 'Editar matéria',
      nomeInicial: subject.nome,
    );
    if (nome == null) return;

    try {
      await ref.read(provedorRepositorioMateria).atualizar(
            Materia(id: subject.id, nome: nome),
          );
      ref.invalidate(provedorMaterias);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Materia subject,
  ) async {
    final confirmed = await mostrarDialogoConfirmarExclusao(
      context,
      titulo: 'Excluir matéria',
      mensagem:
          'Excluir "${subject.nome}"? Também remove das cargas dos cursos, '
          'vínculos com professores e aulas na grade.',
    );
    if (!confirmed) return;

    try {
      await ref.read(provedorRepositorioMateria).excluir(subject.id);
      ref.invalidate(provedorMaterias);
      ref.invalidate(provedorCargasCurso);
      ref.invalidate(provedorProfessorMaterias);
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
    final subjectsAsync = ref.watch(provedorMaterias);

    return ColunaQuadro(
      titulo: 'Matérias',
      icone: Icons.menu_book_outlined,
      acoes: [
        IconButton(
          onPressed: () => _criar(context, ref),
          tooltip: 'Adicionar matéria',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: subjectsAsync.when(
        data: (materias) {
          if (materias.isEmpty) {
            return const DicaColunaVazia(mensagem: 'Nenhuma matéria cadastrada');
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: materias
                .map(
                  (subject) => CartaoItem(
                    titulo: subject.nome,
                    aoEditar: () => _editar(context, ref, subject),
                    aoExcluir: () => _excluir(context, ref, subject),
                  ),
                )
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => DicaColunaVazia(mensagem: 'Erro: $e'),
      ),
    );
  }
}
