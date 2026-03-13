class ResponseModel {
  final String id;
  final String description;
  final String postedByUid;
  final String postedByName;
  final DateTime postedAt;

  ResponseModel({
    required this.id,
    required this.description,
    required this.postedByUid,
    required this.postedByName,
    required this.postedAt,
  });

  factory ResponseModel.fromMap(Map<String, dynamic> map, String docId) {
    final postedBy = Map<String, dynamic>.from(map['postedBy'] as Map);
    return ResponseModel(
      id: docId,
      description: map['description'] ?? '',
      postedByUid: postedBy['uid'] ?? '',
      postedByName: postedBy['name'] ?? '',
      postedAt: DateTime.fromMillisecondsSinceEpoch(map['postedAt'] as int),
    );
  }
}
