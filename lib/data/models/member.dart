class Member {
  final String id;
  final String userId;
  final String name;
  final String surname;
  final String email;
  final String? phone;
  final String role;
  final String generation;
  final DateTime? birthDate;
  final String? avatar;
  final String? bio;
  final List<String> expertise;
  final List<String> committees;
  final int votingPower;
  final String status;
  final DateTime? joinedAt;
  final String? spouse;
  final List<String> children;

  const Member({
    required this.id,
    required this.userId,
    required this.name,
    required this.surname,
    required this.email,
    this.phone,
    required this.role,
    required this.generation,
    this.birthDate,
    this.avatar,
    this.bio,
    this.expertise = const [],
    this.committees = const [],
    this.votingPower = 1,
    this.status = 'Active',
    this.joinedAt,
    this.spouse,
    this.children = const [],
  });

  String get fullName => '$name $surname';

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      generation: json['generation'] as String,
      birthDate: json['birthDate'] != null 
          ? DateTime.tryParse(json['birthDate'] as String) 
          : null,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      expertise: (json['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
      committees: (json['committees'] as List<dynamic>?)?.cast<String>() ?? [],
      votingPower: json['votingPower'] as int? ?? 1,
      status: json['status'] as String? ?? 'Active',
      joinedAt: json['joinedAt'] != null 
          ? DateTime.tryParse(json['joinedAt'] as String) 
          : null,
      spouse: json['spouse'] as String?,
      children: (json['children'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'role': role,
      'generation': generation,
      'birthDate': birthDate?.toIso8601String().split('T').first,
      'avatar': avatar,
      'bio': bio,
      'expertise': expertise,
      'committees': committees,
      'votingPower': votingPower,
      'status': status,
      'joinedAt': joinedAt?.toIso8601String().split('T').first,
      'spouse': spouse,
      'children': children,
    };
  }
}

class MembersSummary {
  final int totalMembers;
  final int activeMembers;
  final int generations;
  final Map<String, int> byRole;

  const MembersSummary({
    required this.totalMembers,
    required this.activeMembers,
    required this.generations,
    required this.byRole,
  });

  factory MembersSummary.fromJson(Map<String, dynamic> json) {
    return MembersSummary(
      totalMembers: json['totalMembers'] as int,
      activeMembers: json['activeMembers'] as int,
      generations: json['generations'] as int,
      byRole: (json['byRole'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }
}
