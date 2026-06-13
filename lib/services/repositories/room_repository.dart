import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/room/room.dart';

class RoomRepository {
  RoomRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// nome da tabela no supabase
  static const String _table = 'tb_sala';

  /// stream em tempo real de todas as salas, ordenadas por número
  /// o supabase reemite a lista sempre que a tabela muda
  Stream<List<Room>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('numero')
        .map((rows) => rows.map(Room.fromJson).toList());
  }

  /// busca pontual de todas as salas (sem realtime)
  Future<List<Room>> fetchAll() async {
    final data = await _client.from(_table).select().order('numero');
    return (data as List)
        .map((row) => Room.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// insere uma nova sala (o id é gerado pelo supabase)
  Future<void> add(int number) async {
    await _client.from(_table).insert({'numero': number});
  }

  /// atualiza o número de uma sala existente
  Future<void> update(Room room) async {
    await _client
        .from(_table)
        .update({'numero': room.number})
        .eq('id', room.id);
  }

  /// remove uma sala pelo id
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
