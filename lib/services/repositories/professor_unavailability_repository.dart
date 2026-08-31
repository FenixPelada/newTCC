import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/components/timetable_grid.dart';
import 'package:flutter_test_project/model/professor/professor_unavailability.dart';

class ProfessorUnavailabilityRepository {
  ProfessorUnavailabilityRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_professor_indisponibilidade';

  Stream<List<ProfessorUnavailability>> watchAll() {
    final controller = StreamController<List<ProfessorUnavailability>>();
    var closed = false;

    Future<void> emit() async {
      try {
        final data = await fetchAll();
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

  Future<List<ProfessorUnavailability>> fetchAll() async {
    final data = await _client.from(_table).select();
    return (data as List)
        .map(
          (row) => ProfessorUnavailability.fromJson(
            row as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> add({
    required String professorId,
    required TimetableSlot slot,
  }) async {
    await _client.from(_table).insert({
      'id_professor': int.parse(professorId),
      'dia_semana': slot.dayIndex + 1,
      'periodo': slot.periodIndex + 1,
    });
  }

  Future<void> deleteByProfessorSlot({
    required String professorId,
    required TimetableSlot slot,
  }) async {
    await _client
        .from(_table)
        .delete()
        .eq('id_professor', int.parse(professorId))
        .eq('dia_semana', slot.dayIndex + 1)
        .eq('periodo', slot.periodIndex + 1);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', int.parse(id));
  }
}
