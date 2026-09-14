import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/professor/indisponibilidade_professor.dart';

class RepositorioIndisponibilidade {
  RepositorioIndisponibilidade({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_professor_indisponibilidade';

  Stream<List<IndisponibilidadeProfessor>> observarTodos() {
    final controller = StreamController<List<IndisponibilidadeProfessor>>();
    var closed = false;

    Future<void> emit() async {
      try {
        final data = await buscarTodos();
        if (!closed && !controller.isClosed) {
          controller.add(data);
        }
      } catch (error, stackTrace) {
        if (!closed && !controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    final channel = _client
        .channel('watch:$_table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _table,
          callback: (_) => unawaited(emit()),
        )
        .subscribe();

    unawaited(emit());

    controller.onCancel = () async {
      closed = true;
      await _client.removeChannel(channel);
      if (!controller.isClosed) {
        await controller.close();
      }
    };

    return controller.stream;
  }

  Future<List<IndisponibilidadeProfessor>> buscarTodos() async {
    final data = await _client.from(_table).select();
    return (data as List)
        .map(
          (row) => IndisponibilidadeProfessor.fromJson(
            row as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> adicionar({
    required String idProfessor,
    required CelulaGrade celula,
  }) async {
    await _client.from(_table).insert({
      'id_professor': int.parse(idProfessor),
      'dia_semana': celula.indiceDia + 1,
      'periodo': celula.indicePeriodo + 1,
    });
  }

  Future<void> excluirPorProfessorCelula({
    required String idProfessor,
    required CelulaGrade celula,
  }) async {
    await _client
        .from(_table)
        .delete()
        .eq('id_professor', int.parse(idProfessor))
        .eq('dia_semana', celula.indiceDia + 1)
        .eq('periodo', celula.indicePeriodo + 1);
  }

  Future<void> excluir(String id) async {
    await _client.from(_table).delete().eq('id', int.parse(id));
  }

  Future<void> excluirPorProfessor(String idProfessor) async {
    await _client
        .from(_table)
        .delete()
        .eq('id_professor', int.parse(idProfessor));
  }
}
