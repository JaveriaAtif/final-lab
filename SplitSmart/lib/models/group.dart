class Group {
  final String id;
  final String name;
  final List<String> memberUsernames;
  final String adminUsername;

  Group({
    required this.id,
    required this.name,
    required this.memberUsernames,
    required this.adminUsername,
  });

  factory Group.fromMap(Map<String, dynamic> map, String id) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      memberUsernames: List<String>.from(map['memberUsernames'] ?? []),
      adminUsername: map['adminUsername'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'memberUsernames': memberUsernames,
      'adminUsername': adminUsername
    };
  }
}
