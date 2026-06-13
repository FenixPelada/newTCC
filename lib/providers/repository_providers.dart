import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/services/repositories/room_repository.dart';

// providers que entregam os repositórios (acesso ao supabase)

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => RoomRepository(),
);
