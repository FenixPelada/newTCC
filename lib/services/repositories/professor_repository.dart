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
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('nome')
        .map((rows) => rows.map(Professor.fromJson).toList());
  }

  Stream<List<ProfessorSubject>> watchSubjectLinks() {
    return _client
        .from(_linkTable)
        .stream(primaryKey: ['id_professor', 'id_materia'])
        .map((rows) => rows.map(ProfessorSubject.fromJson).toList());
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
