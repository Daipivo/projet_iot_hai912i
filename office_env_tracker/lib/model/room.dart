class Room {
  final String id;
  final String name;
  final String ipAddress;

  Room({
    required this.id,
    required this.name,
    required this.ipAddress,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      ipAddress: json['ipAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
    };
  }
}
