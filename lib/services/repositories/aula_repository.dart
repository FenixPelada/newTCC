import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/aula/aula.dart';

class AulaRepository {
  AulaRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_aula';

  Stream<List<Aula>> watchAll() {
    return _watchTable(fetch: fetchAll);
  }

  Stream<List<Aula>> watchByCourse(String courseId) {
    return _watchTable(fetch: () => fetchByCourse(courseId));
  }

  Stream<List<Aula>> _watchTable({
    required Future<List<Aula>> Function() fetch,
  }) {
    final controller = StreamController<List<Aula>>();
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

  Future<List<Aula>> fetchAll() async {
    final data = await _client.from(_table).select();
    return (data as List)
        .map((row) => Aula.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Aula>> fetchByCourse(String courseId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('id_curso', int.parse(courseId));
    return (data as List)
        .map((row) => Aula.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> add(Aula aula) async {
    final row = await _client
        .from(_table)
        .insert(aula.toInsertJson())
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> update(Aula aula) async {
    await _client
        .from(_table)
        .update({
          'id_materia': int.parse(aula.subjectId),
          'id_professor': int.parse(aula.professorId),
          'id_sala': aula.roomId == null ? null : int.parse(aula.roomId!),
        })
        .eq('id', int.parse(aula.id));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', int.parse(id));
  }

  Future<void> deleteByCourse(String courseId) async {
    await _client
        .from(_table)
        .delete()
        .eq('id_curso', int.parse(courseId));
  }

  Future<void> deleteAll() async {
    await _client.from(_table).delete().neq('id', 0);
  }
}
