import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/components/coluna_quadro.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_confirmar_exclusao.dart';
import 'package:flutter_test_project/components/dialogs/dialogo_numero.dart';
import 'package:flutter_test_project/components/cartao_item.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/providers/providers.dart';

class ColunaSala extends ConsumerWidget {
  const ColunaSala({super.key});

  Future<void> _criar(BuildContext context, WidgetRef ref) async {
    final numero = await mostrarDialogoNumero(
      context,
      titulo: 'Nova sala',
      rotulo: 'Número da sala',
    );
    if (numero == null) return;

    try {
      await ref.read(provedorRepositorioSala).adicionar(numero);
      ref.invalidate(provedorSalas);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _editar(
    BuildContext context,
    WidgetRef ref,
    Sala room,
  ) async {
    final numero = await mostrarDialogoNumero(
      context,
      titulo: 'Editar sala',
      rotulo: 'Número da sala',
      numeroInicial: room.numero,
    );
    if (numero == null) return;

    try {
      await ref.read(provedorRepositorioSala).atualizar(
            Sala(id: room.id, numero: numero),
          );
      ref.invalidate(provedorSalas);
    } catch (e) {
      if (!context.mounted) return;
      _mostrarErro(context, e);
    }
  }

  Future<void> _excluir(
    BuildContext context,
    WidgetRef ref,
    Sala room,
  ) async {
    final confirmed = await mostrarDialogoConfirmarExclusao(
      context,
      titulo: 'Excluir sala',
      mensagem:
          'Excluir a Sala ${room.numero}? Cursos e aulas que usavam esta '
          'sala ficam sem sala.',
    );
    if (!confirmed) return;

    try {
      await ref.read(provedorRepositorioSala).excluir(room.id);
      ref.invalidate(provedorSalas);
      ref.invalidate(provedorCursos);
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
    final roomsAsync = ref.watch(provedorSalas);

    return ColunaQuadro(
      titulo: 'Salas',
      icone: Icons.meeting_room_outlined,
      acoes: [
        IconButton(
          onPressed: () => _criar(context, ref),
          tooltip: 'Adicionar sala',
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: roomsAsync.when(
        data: (salas) {
          if (salas.isEmpty) {
            return const DicaColunaVazia(mensagem: 'Nenhuma sala cadastrada');
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: salas
                .map(
                  (room) => CartaoItem(
                    titulo: 'Sala ${room.numero}',
                    aoEditar: () => _editar(context, ref, room),
                    aoExcluir: () => _excluir(context, ref, room),
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
