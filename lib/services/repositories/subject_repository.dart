import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/subject/subject.dart';

class SubjectRepository {
  SubjectRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_materia';

  Stream<List<Subject>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('nome')
        .map((rows) => rows.map(Subject.fromJson).toList());
  }

  Future<List<Subject>> fetchAll() async {
    final data = await _client.from(_table).select().order('nome');
    return (data as List)
        .map((row) => Subject.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> add(String name) async {
    final row = await _client
        .from(_table)
        .insert({'nome': name})
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> update(Subject subject) async {
    await _client
        .from(_table)
        .update({'nome': subject.name})
        .eq('id', int.parse(subject.id));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', int.parse(id));
  }
}
