import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test_project/model/curso/aula_geminada_curso.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/curso/preferencia_periodo.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';

class RepositorioCurso {
  RepositorioCurso({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'tb_curso';
  static const String _loadTable = 'tb_curso_materia';
  static const String _geminatedTable = 'tb_curso_aula_geminada';

  Stream<List<Curso>> observarTodos() {
    return _watchTable<Curso>(
      table: _table,
      channelName: 'watch:$_table',
      fetch: buscarTodos,
    );
  }

  Stream<List<CargaCursoMateria>> observarCargas() {
    return _watchTable<CargaCursoMateria>(
      table: _loadTable,
      channelName: 'watch:$_loadTable',
      fetch: buscarTodasCargas,
    );
  }

  Stream<List<AulaGeminadaCurso>> observarAulasGeminadas() {
    return _watchTable<AulaGeminadaCurso>(
      table: _geminatedTable,
      channelName: 'watch:$_geminatedTable',
      fetch: buscarTodasAulasGeminadas,
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

  Future<List<Curso>> buscarTodos() async {
    final data = await _client.from(_table).select().order('nome');
    return (data as List)
        .map((row) => Curso.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<CargaCursoMateria>> buscarTodasCargas() async {
    final data = await _client.from(_loadTable).select();
    return (data as List)
        .map((row) => CargaCursoMateria.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<CargaCursoMateria>> buscarCargas(String idCurso) async {
    final data = await _client
        .from(_loadTable)
        .select()
        .eq('id_curso', int.parse(idCurso));
    return (data as List)
        .map((row) => CargaCursoMateria.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<AulaGeminadaCurso>> buscarTodasAulasGeminadas() async {
    try {
      final data = await _client.from(_geminatedTable).select();
      return (data as List)
          .map((row) => AulaGeminadaCurso.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') return const [];
      rethrow;
    }
  }

  Future<List<AulaGeminadaCurso>> buscarAulasGeminadas(String idCurso) async {
    try {
      final data = await _client
          .from(_geminatedTable)
          .select()
          .eq('id_curso', int.parse(idCurso));
      return (data as List)
          .map((row) => AulaGeminadaCurso.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') return const [];
      rethrow;
    }
  }

  Future<String> adicionar(
    String nome, {
    String? idSala,
    PreferenciaPeriodo preferenciaPeriodo = PreferenciaPeriodo.manhaTarde,
    bool turnoCompartilhado = false,
    List<CargaCursoMateria> cargas = const [],
    List<AulaGeminadaCurso> aulasGeminadas = const [],
  }) async {
    final payload = <String, dynamic>{
      'nome': nome,
      'id_sala': idSala == null ? null : int.parse(idSala),
      'periodo_preferencia': preferenciaPeriodo.toDb(),
      'turno_compartilhado': turnoCompartilhado,
    };
    final row = await _client
        .from(_table)
        .insert(payload)
        .select('id')
        .single();
    final id = row['id'].toString();
    await definirCargas(id, cargas);
    await definirAulasGeminadas(id, aulasGeminadas);
    return id;
  }

  Future<void> atualizar(
    Curso course, {
    List<CargaCursoMateria>? cargas,
    List<AulaGeminadaCurso>? aulasGeminadas,
  }) async {
    await _client
        .from(_table)
        .update({
          'nome': course.nome,
          'id_sala': course.idSala == null ? null : int.parse(course.idSala!),
          'periodo_preferencia': course.preferenciaPeriodo.toDb(),
          'turno_compartilhado': course.turnoCompartilhado,
        })
        .eq('id', int.parse(course.id));
    if (cargas != null) {
      await definirCargas(course.id, cargas);
    }
    if (aulasGeminadas != null) {
      await definirAulasGeminadas(course.id, aulasGeminadas);
    }
  }

  Future<void> definirAulasGeminadas(
    String idCurso,
    List<AulaGeminadaCurso> aulasGeminadas,
  ) async {
    final parsedCourseId = int.parse(idCurso);
    try {
      await _client
          .from(_geminatedTable)
          .delete()
          .eq('id_curso', parsedCourseId);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205' && aulasGeminadas.isEmpty) return;
      rethrow;
    }

    final unicas = <String, AulaGeminadaCurso>{};
    for (final par in aulasGeminadas) {
      unicas[par.chave] = par;
    }

    if (unicas.isEmpty) return;

    await _client
        .from(_geminatedTable)
        .insert(
          unicas.values
              .map((par) => par.toInsertJson(idCursoOverride: idCurso))
              .toList(),
        );
  }

  Future<void> definirCargas(
    String idCurso,
    List<CargaCursoMateria> cargas,
  ) async {
    final parsedCourseId = int.parse(idCurso);
    await _client.from(_loadTable).delete().eq('id_curso', parsedCourseId);

    if (cargas.isNotEmpty) {
      await _client
          .from(_loadTable)
          .insert(
            cargas
                .map(
                  (load) => {
                    'id_curso': parsedCourseId,
                    'id_materia': int.parse(load.idMateria),
                    'quantidade_aulas': load.quantidadeAulas,
                    'tamanho_bloco': load.tamanhoBloco,
                  },
                )
                .toList(),
          );
    }

    // Remove aulas de matérias que saíram da carga deste curso.
    final idsPermitidos = cargas.map((c) => c.idMateria).toSet();
    final aulas = await _client
        .from('tb_aula')
        .select('id, id_materia')
        .eq('id_curso', parsedCourseId);
    for (final row in aulas as List) {
      final mapa = row as Map<String, dynamic>;
      final idMateria = mapa['id_materia'].toString();
      if (!idsPermitidos.contains(idMateria)) {
        await _client.from('tb_aula').delete().eq('id', mapa['id']);
      }
    }
  }

  Future<void> excluir(String id) async {
    final parsedId = int.parse(id);
    await _client.from('tb_aula').delete().eq('id_curso', parsedId);
    await _client.from(_loadTable).delete().eq('id_curso', parsedId);
    try {
      await _client.from(_geminatedTable).delete().eq('id_curso', parsedId);
    } on PostgrestException catch (e) {
      if (e.code != 'PGRST205') rethrow;
    }
    await _client.from(_table).delete().eq('id', parsedId);
  }
}
