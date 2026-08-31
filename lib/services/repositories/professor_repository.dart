import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/professor/professor_subject.dart';

class ProfessorRepository {
  ProfessorRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_professor';
  static const String _linkTable = 'tb_professor_materia';

  Stream<List<Professor>> watchAll() {
    return _watchTable<Professor>(
      table: _table,
      channelName: 'watch:$_table',
      fetch: fetchAll,
    );
  }

  Stream<List<ProfessorSubject>> watchSubjectLinks() {
    return _watchTable<ProfessorSubject>(
      table: _linkTable,
      channelName: 'watch:$_linkTable',
      fetch: fetchAllLinks,
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

  Future<List<Professor>> fetchAll() async {
    final data = await _client.from(_table).select().order('nome');
    return (data as List)
        .map((row) => Professor.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProfessorSubject>> fetchAllLinks() async {
    final data = await _client.from(_linkTable).select();
    return (data as List)
        .map(
          (row) => ProfessorSubject.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<String>> fetchSubjectIds(String professorId) async {
    final data = await _client
        .from(_linkTable)
        .select('id_materia')
        .eq('id_professor', int.parse(professorId));
    return (data as List)
        .map((row) => (row as Map<String, dynamic>)['id_materia'].toString())
        .toList();
  }

  Future<String> add(String name, {List<String> subjectIds = const []}) async {
    final row = await _client
        .from(_table)
        .insert({'nome': name})
        .select('id')
        .single();
    final id = row['id'].toString();
    await setSubjects(id, subjectIds);
    return id;
  }

  Future<void> update(
    Professor professor, {
    List<String>? subjectIds,
  }) async {
    await _client
        .from(_table)
        .update({'nome': professor.name})
        .eq('id', int.parse(professor.id));
    if (subjectIds != null) {
      await setSubjects(professor.id, subjectIds);
    }
  }

  Future<void> setSubjects(String professorId, List<String> subjectIds) async {
    final parsedProfessorId = int.parse(professorId);
    await _client
        .from(_linkTable)
        .delete()
        .eq('id_professor', parsedProfessorId);

    if (subjectIds.isEmpty) return;

    await _client.from(_linkTable).insert(
          subjectIds
              .map(
                (subjectId) => {
                  'id_professor': parsedProfessorId,
                  'id_materia': int.parse(subjectId),
                },
              )
              .toList(),
        );
  }

  Future<void> delete(String id) async {
    final parsedId = int.parse(id);
    await _client.from(_linkTable).delete().eq('id_professor', parsedId);
    await _client.from(_table).delete().eq('id', parsedId);
  }
}
