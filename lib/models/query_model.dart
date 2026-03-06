class QueryModel {
  final String id;
  final String description;
  final String campus;
  final String postedByUid;
  final String postedByName;
  final DateTime postedAt;
  final int responseCount;

  QueryModel({
    required this.id,
    required this.description,
    required this.campus,
    required this.postedByUid,
    required this.postedByName,
    required this.postedAt,
    required this.responseCount,
  });

  factory QueryModel.fromMap(Map<String, dynamic> map, String docId) {
    final postedBy = Map<String, dynamic>.from(map['postedBy'] as Map);
    return QueryModel(
      id: docId,
      description: map['description'] ?? '',
      campus: map['campus'] ?? '',
      postedByUid: postedBy['uid'] ?? '',
      postedByName: postedBy['name'] ?? '',
      postedAt: DateTime.fromMillisecondsSinceEpoch(map['postedAt'] as int),
      responseCount: int.parse(map['responseCount'].toString()),
    );
  }
}
