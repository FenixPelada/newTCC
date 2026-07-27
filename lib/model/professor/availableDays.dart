enum Availabledays {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get labelPt {
    switch (this) {
      case Availabledays.monday:
        return 'Segunda-feira';
      case Availabledays.tuesday:
        return 'Terça-feira';
      case Availabledays.wednesday:
        return 'Quarta-feira';
      case Availabledays.thursday:
        return 'Quinta-feira';
      case Availabledays.friday:
        return 'Sexta-feira';
      case Availabledays.saturday:
        return 'Sábado';
      case Availabledays.sunday:
        return 'Domingo';
    }
  }
}
