enum PreferenciaPeriodo {
  manhaTarde,
  tardeManha;

  static PreferenciaPeriodo fromDb(String? value) => switch (value) {
    'tarde' || 'tarde_manha' => PreferenciaPeriodo.tardeManha,
    _ => PreferenciaPeriodo.manhaTarde,
  };

  String toDb() => switch (this) {
    PreferenciaPeriodo.manhaTarde => 'manha_tarde',
    PreferenciaPeriodo.tardeManha => 'tarde_manha',
  };

  String get rotulo => switch (this) {
    PreferenciaPeriodo.manhaTarde => 'Manhã, depois tarde',
    PreferenciaPeriodo.tardeManha => 'Tarde, depois manhã',
  };
}
