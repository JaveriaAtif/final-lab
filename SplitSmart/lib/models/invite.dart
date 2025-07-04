class GroupInvite {
  final String id;
  final String groupId;
  final String invitedUserId;
  final String invitedByUserId;
  final DateTime sentAt;
  final bool accepted;

  GroupInvite({
    required this.id,
    required this.groupId,
    required this.invitedUserId,
    required this.invitedByUserId,
    required this.sentAt,
    required this.accepted,
  });

  factory GroupInvite.fromMap(Map<String, dynamic> map, String id) {
    return GroupInvite(
      id: id,
      groupId: map['groupId'] ?? '',
      invitedUserId: map['invitedUserId'] ?? '',
      invitedByUserId: map['invitedByUserId'] ?? '',
      sentAt: DateTime.parse(map['sentAt']),
      accepted: map['accepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'invitedUserId': invitedUserId,
      'invitedByUserId': invitedByUserId,
      'sentAt': sentAt.toIso8601String(),
      'accepted': accepted,
    };
  }
} 