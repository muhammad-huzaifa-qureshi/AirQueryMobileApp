import 'package:cloud_firestore/cloud_firestore.dart';

class QueryModel {
  final String id;
  final String description;
  final String campus;
  final String postedByUid;
  final String postedByName;
  final DateTime postedAt;
  final int responseCount;
  final bool isResolved;
  final String? imagePath;

  QueryModel({
    required this.id,
    required this.description,
    required this.campus,
    required this.postedByUid,
    required this.postedByName,
    required this.postedAt,
    required this.responseCount,
    required this.isResolved,
    this.imagePath,
  });

  factory QueryModel.fromMap(Map<String, dynamic> map, String docId) {
    final postedBy = Map<String, dynamic>.from(map['postedBy'] as Map);
    return QueryModel(
      id: docId,
      description: map['description'] ?? '',
      campus: map['campus'] ?? '',
      postedByUid: postedBy['uid'] ?? '',
      postedByName: postedBy['name'] ?? '',
      postedAt: (map['postedAt'] as Timestamp).toDate(),
      responseCount: int.parse(map['responseCount'].toString()),
      isResolved: map['isResolved'] ?? false,
      imagePath: map['imagePath'] as String?,
    );
  }

  QueryModel copyWith({
    String? id,
    String? description,
    String? campus,
    String? postedByUid,
    String? postedByName,
    DateTime? postedAt,
    int? responseCount,
    bool? isResolved,
    String? imagePath
  }) {
    return QueryModel(
      id: id ?? this.id,
      description: description ?? this.description,
      campus: campus ?? this.campus,
      postedByUid: postedByUid ?? this.postedByUid,
      postedByName: postedByName ?? this.postedByName,
      postedAt: postedAt ?? this.postedAt,
      responseCount: responseCount ?? this.responseCount,
      isResolved: isResolved ?? this.isResolved,
      imagePath: imagePath ?? this.imagePath
    );
  }
}
