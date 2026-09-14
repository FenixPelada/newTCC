class Materia {
  Materia({required this.id, required this.nome});

  final String id;
  final String nome;

  factory Materia.fromJson(Map<String, dynamic> json) => Materia(
        id: json['id'].toString(),
        nome: json['nome'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
      };

  Map<String, dynamic> toInsertJson() => {
        'nome': nome,
      };
}
