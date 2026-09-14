class Sala {
  Sala({required this.id, required this.numero});

  final String id;
  final int numero;

  factory Sala.fromJson(Map<String, dynamic> json) => Sala(
        id: json['id'].toString(),
        numero: (json['numero'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
      };

  Map<String, dynamic> toInsertJson() => {
        'numero': numero,
      };
}
