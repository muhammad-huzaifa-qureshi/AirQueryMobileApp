class UserModel {
  final String uid;
  final String name;
  final String role;
  final String? about;
  final bool isInsider;
  final int queriesPosted;
  final int responsesPosted;
  final int queriesResolved;
  final bool profileComplete;
  final bool isPremium;

  UserModel({
    required this.uid,
    required this.name,
    required this.role,
    required this.about,
    required this.isInsider,
    required this.queriesPosted,
    required this.responsesPosted,
    required this.queriesResolved,
    required this.profileComplete,
    this.isPremium = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      about: map['about'] ?? '',
      isInsider: map['isInsider'] ?? false,
      queriesPosted: int.parse((map['queriesPosted'] ?? 0).toString()),
      responsesPosted: int.parse((map['responsesPosted'] ?? 0).toString()),
      queriesResolved: int.parse((map['queriesResolved'] ?? 0).toString()),
      profileComplete: map['profileComplete'] ?? false,
      isPremium: map['isPremium'] ?? false,
    );
  }
}
