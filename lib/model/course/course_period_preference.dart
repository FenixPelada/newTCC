enum CoursePeriodPreference {
  manha,
  tarde,
  contraturno;

  static CoursePeriodPreference fromDb(String? value) => switch (value) {
        'tarde' => CoursePeriodPreference.tarde,
        'contraturno' => CoursePeriodPreference.contraturno,
        _ => CoursePeriodPreference.manha,
      };

  String toDb() => name;

  String get label => switch (this) {
        CoursePeriodPreference.manha => 'Manhã',
        CoursePeriodPreference.tarde => 'Tarde',
        CoursePeriodPreference.contraturno => 'Contraturno',
      };
}
