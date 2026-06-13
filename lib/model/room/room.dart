class Room {
  Room({required this.id, required this.number});

  final String id;
  final int number;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'].toString(),
        number: json['numero'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': number,
      };

  Map<String, dynamic> toInsertJson() => {
        'numero': number,
      };
}
