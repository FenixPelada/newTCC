class AulaGeminadaCurso {
  AulaGeminadaCurso({
    required this.idCurso,
    required String idMateriaA,
    required String idMateriaB,
  }) : idMateriaA = _primeiroId(idMateriaA, idMateriaB),
       idMateriaB = _segundoId(idMateriaA, idMateriaB);

  final String idCurso;
  final String idMateriaA;
  final String idMateriaB;

  factory AulaGeminadaCurso.fromJson(Map<String, dynamic> json) =>
      AulaGeminadaCurso(
        idCurso: json['id_curso'].toString(),
        idMateriaA: json['id_materia_a'].toString(),
        idMateriaB: json['id_materia_b'].toString(),
      );

  Map<String, dynamic> toInsertJson({String? idCursoOverride}) => {
    'id_curso': int.parse(idCursoOverride ?? idCurso),
    'id_materia_a': int.parse(idMateriaA),
    'id_materia_b': int.parse(idMateriaB),
  };

  bool contemMateria(String idMateria) =>
      idMateriaA == idMateria || idMateriaB == idMateria;

  bool formaPar(String primeira, String segunda) {
    final normalizado = AulaGeminadaCurso(
      idCurso: idCurso,
      idMateriaA: primeira,
      idMateriaB: segunda,
    );
    return idMateriaA == normalizado.idMateriaA &&
        idMateriaB == normalizado.idMateriaB;
  }

  String get chave => '$idCurso:$idMateriaA:$idMateriaB';

  static String _primeiroId(String a, String b) {
    final numeroA = int.tryParse(a);
    final numeroB = int.tryParse(b);
    if (numeroA != null && numeroB != null) {
      return numeroA <= numeroB ? a : b;
    }
    return a.compareTo(b) <= 0 ? a : b;
  }

  static String _segundoId(String a, String b) {
    final primeiro = _primeiroId(a, b);
    return primeiro == a ? b : a;
  }
}

bool existeAulaGeminada({
  required String idCurso,
  required String idMateriaA,
  required String idMateriaB,
  required List<AulaGeminadaCurso> aulasGeminadas,
}) {
  return aulasGeminadas.any(
    (par) => par.idCurso == idCurso && par.formaPar(idMateriaA, idMateriaB),
  );
}

List<String> materiasGeminadasCom({
  required String idCurso,
  required String idMateria,
  required List<AulaGeminadaCurso> aulasGeminadas,
}) {
  final ids = <String>{};
  for (final par in aulasGeminadas) {
    if (par.idCurso != idCurso || !par.contemMateria(idMateria)) continue;
    ids.add(par.idMateriaA == idMateria ? par.idMateriaB : par.idMateriaA);
  }
  return ids.toList();
}
