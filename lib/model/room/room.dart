class Room {
  Room({required this.id, required this.number});

  final String id;
  final int number;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        // toString() cobre id uuid (String) e id int/bigint sem quebrar.
        id: json['id'].toString(),
        number: json['numero'] as int,
      );

  /// Payload completo (inclui o id) — útil para update.
  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': number,
      };

  /// Payload de insert: omite o id para deixar o Supabase gerá-lo.
  Map<String, dynamic> toInsertJson() => {
        'numero': number,
      };
}
