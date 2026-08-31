import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/room/room.dart';

class RoomRepository {
  RoomRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_sala';

  Stream<List<Room>> watchAll() {
    final controller = StreamController<List<Room>>();
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

  Future<List<Room>> fetchAll() async {
    final data = await _client.from(_table).select().order('numero');
    return (data as List)
        .map((row) => Room.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<String> add(int number) async {
    final row = await _client
        .from(_table)
        .insert({'numero': number})
        .select('id')
        .single();
    return row['id'].toString();
  }

  Future<void> update(Room room) async {
    await _client
        .from(_table)
        .update({'numero': room.number})
        .eq('id', int.parse(room.id));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', int.parse(id));
  }
}
