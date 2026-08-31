import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/course/course.dart';
import 'package:flutter_test_project/model/course/course_period_preference.dart';
import 'package:flutter_test_project/model/course/course_subject_load.dart';

class CourseRepository {
  CourseRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_curso';
  static const String _loadTable = 'tb_curso_materia';

  Stream<List<Course>> watchAll() {
    return _watchTable<Course>(
      table: _table,
      channelName: 'watch:$_table',
      fetch: fetchAll,
    );
  }

  Stream<List<CourseSubjectLoad>> watchLoads() {
    return _watchTable<CourseSubjectLoad>(
      table: _loadTable,
      channelName: 'watch:$_loadTable',
      fetch: fetchAllLoads,
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
          callback: (_) {
            unawaited(emit());
          },
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

  Future<List<Course>> fetchAll() async {
    final data = await _client.from(_table).select().order('nome');
    return (data as List)
        .map((row) => Course.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<CourseSubjectLoad>> fetchAllLoads() async {
    final data = await _client.from(_loadTable).select();
    return (data as List)
        .map(
          (row) => CourseSubjectLoad.fromJson(row as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<CourseSubjectLoad>> fetchLoads(String courseId) async {
    final data = await _client
        .from(_loadTable)
        .select()
        .eq('id_curso', int.parse(courseId));
    return (data as List)
        .map((row) => CourseSubjectLoad.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> add(
    String name, {
    String? roomId,
    CoursePeriodPreference periodPreference = CoursePeriodPreference.manha,
    List<CourseSubjectLoad> loads = const [],
  }) async {
    final payload = <String, dynamic>{
      'nome': name,
      'id_sala': roomId == null ? null : int.parse(roomId),
      'periodo_preferencia': periodPreference.toDb(),
    };
    final row = await _client
        .from(_table)
        .insert(payload)
        .select('id')
        .single();
    final id = row['id'].toString();
    await setLoads(id, loads);
    return id;
  }

  Future<void> update(
    Course course, {
    List<CourseSubjectLoad>? loads,
  }) async {
    await _client.from(_table).update({
      'nome': course.name,
      'id_sala':
          course.roomId == null ? null : int.parse(course.roomId!),
      'periodo_preferencia': course.periodPreference.toDb(),
    }).eq('id', int.parse(course.id));
    if (loads != null) {
      await setLoads(course.id, loads);
    }
  }

  Future<void> setLoads(String courseId, List<CourseSubjectLoad> loads) async {
    final parsedCourseId = int.parse(courseId);
    await _client.from(_loadTable).delete().eq('id_curso', parsedCourseId);

    if (loads.isEmpty) return;

    await _client.from(_loadTable).insert(
          loads
              .map(
                (load) => {
                  'id_curso': parsedCourseId,
                  'id_materia': int.parse(load.subjectId),
                  'quantidade_aulas': load.classCount,
                  'tamanho_bloco': load.blockSize,
                },
              )
              .toList(),
        );
  }

  Future<void> delete(String id) async {
    final parsedId = int.parse(id);
    await _client.from(_loadTable).delete().eq('id_curso', parsedId);
    await _client.from(_table).delete().eq('id', parsedId);
  }
}
