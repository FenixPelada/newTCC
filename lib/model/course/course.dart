class Course {
  Course({required this.id, required this.name});

  final String id;
  final String name;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
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
