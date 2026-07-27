class Subject {
  Subject({required this.id, required this.name});

  final String id;
  final String name;

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
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
