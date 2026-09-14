import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_materia.dart';

class RepositorioProfessor {
  RepositorioProfessor({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_professor';
  static const String _linkTable = 'tb_professor_materia';

  Stream<List<Professor>> observarTodos() {
    return _watchTable<Professor>(
      table: _table,
      channelName: 'watch:$_table',
      fetch: buscarTodos,
    );
  }

  Stream<List<ProfessorMateria>> observarLigacoesMaterias() {
    return _watchTable<ProfessorMateria>(
      table: _linkTable,
      channelName: 'watch:$_linkTable',
      fetch: buscarTodasLigacoes,
    );
  }

  Stream<List<T>> _watchTable<T>({
    required String table,
    required String channelName,
    required Future<List<T>> Function() fetch,
  }) {
    final controller = StreamController<List<T>>();
    var closed = false;

    Future<void> emit() async {
      try {
        final data = await fetch();
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
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
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

  Future<List<Professor>> buscarTodos() async {
    final data = await _client.from(_table).select().order('nome');
    return (data as List)
        .map((row) => Professor.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProfessorMateria>> buscarTodasLigacoes() async {
    final data = await _client.from(_linkTable).select();
    return (data as List)
        .map(
          (row) => ProfessorMateria.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<String>> buscarIdsMaterias(String idProfessor) async {
    final data = await _client
        .from(_linkTable)
        .select('id_materia')
        .eq('id_professor', int.parse(idProfessor));
    return (data as List)
        .map((row) => (row as Map<String, dynamic>)['id_materia'].toString())
        .toList();
  }

  Future<String> adicionar(String nome, {List<String> idsMaterias = const []}) async {
    final row = await _client
        .from(_table)
        .insert({'nome': nome})
        .select('id')
        .single();
    final id = row['id'].toString();
    await definirMaterias(id, idsMaterias);
    return id;
  }

  Future<void> atualizar(
    Professor professor, {
    List<String>? idsMaterias,
  }) async {
    await _client
        .from(_table)
        .update({'nome': professor.nome})
        .eq('id', int.parse(professor.id));
    if (idsMaterias != null) {
      await definirMaterias(professor.id, idsMaterias);
    }
  }

  Future<void> definirMaterias(String idProfessor, List<String> idsMaterias) async {
    final parsedProfessorId = int.parse(idProfessor);
    await _client
        .from(_linkTable)
        .delete()
        .eq('id_professor', parsedProfessorId);

    if (idsMaterias.isEmpty) return;

    await _client.from(_linkTable).insert(
          idsMaterias
              .map(
                (idMateria) => {
                  'id_professor': parsedProfessorId,
                  'id_materia': int.parse(idMateria),
                },
              )
              .toList(),
        );
  }

  Future<void> excluir(String id) async {
    final parsedId = int.parse(id);
    await _client.from('tb_aula').delete().eq('id_professor', parsedId);
    await _client
        .from('tb_professor_indisponibilidade')
        .delete()
        .eq('id_professor', parsedId);
    await _client.from(_linkTable).delete().eq('id_professor', parsedId);
    await _client.from(_table).delete().eq('id', parsedId);
  }
}
