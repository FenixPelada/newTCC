import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/sala/sala.dart';

class RepositorioSala {
  RepositorioSala({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_sala';

  Stream<List<Sala>> observarTodos() {
    final controller = StreamController<List<Sala>>();
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

  Future<List<Sala>> buscarTodos() async {
    final data = await _client.from(_table).select().order('numero');
    return (data as List)
        .map((row) => Sala.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> adicionar(int numero) async {
    final row = await _client
        .from(_table)
        .insert({'numero': numero})
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> atualizar(Sala room) async {
    await _client
        .from(_table)
        .update({'numero': room.numero})
        .eq('id', int.parse(room.id));
  }

  Future<void> excluir(String id) async {
    final parsedId = int.parse(id);
    await _client
        .from('tb_aula')
        .update({'id_sala': null})
        .eq('id_sala', parsedId);
    await _client
        .from('tb_curso')
        .update({'id_sala': null})
        .eq('id_sala', parsedId);
    await _client.from(_table).delete().eq('id', parsedId);
  }
}
