class User {
  String username;
  String email;
  String password;
  final List<String> groupIds;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.groupIds,
  });

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      groupIds: List<String>.from(map['groupIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'groupIds': groupIds,
    };
  }
}
