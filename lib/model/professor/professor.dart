class Professor {
  Professor({required this.id, required this.name});

  final String id;
  final String name;

  factory Professor.fromJson(Map<String, dynamic> json) => Professor(
        id: json['id'].toString(),
        name: json['nome'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': name,
      };

  Map<String, dynamic> toInsertJson() => {
        'nome': name,
      };
}
