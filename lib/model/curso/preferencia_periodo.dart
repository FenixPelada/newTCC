enum PreferenciaPeriodo {
  manha,
  tarde,
  contraturno;

  static PreferenciaPeriodo fromDb(String? value) => switch (value) {
        'tarde' => PreferenciaPeriodo.tarde,
        'contraturno' => PreferenciaPeriodo.contraturno,
        _ => PreferenciaPeriodo.manha,
      };

  String toDb() => name;

  String get rotulo => switch (this) {
        PreferenciaPeriodo.manha => 'Manhã',
        PreferenciaPeriodo.tarde => 'Tarde',
        PreferenciaPeriodo.contraturno => 'Contraturno',
      };
}
