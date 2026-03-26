class UserModel {
  final String uid;
  final String name;
  final String campus;
  final String semester;
  final int queriesPosted;
  final int responsesPosted;
  final int queriesResolved;
  final bool profileComplete;

  UserModel({
    required this.uid,
    required this.name,
    required this.campus,
    required this.semester,
    required this.queriesPosted,
    required this.responsesPosted,
    required this.queriesResolved,
    required this.profileComplete,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      campus: map['campus'] ?? '',
      semester: map['semester'] ?? '',
      queriesPosted: int.parse((map['queriesPosted'] ?? 0).toString()),
      responsesPosted: int.parse((map['responsesPosted'] ?? 0).toString()),
      queriesResolved: int.parse((map['queriesResolved'] ?? 0).toString()),
      profileComplete: map['profileComplete'] ?? false,
    );
  }
}
