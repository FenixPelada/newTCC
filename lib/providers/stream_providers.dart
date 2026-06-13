import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test_project/model/room/room.dart';
import 'package:flutter_test_project/providers/repository_providers.dart';

// streamProviders: escutam os streams realtime dos repos

/// usa .when(loading:, error:, data:) pra renderizar
final roomsProvider = StreamProvider<List<Room>>((ref) {
  return ref.read(roomRepositoryProvider).watchAll();
});
