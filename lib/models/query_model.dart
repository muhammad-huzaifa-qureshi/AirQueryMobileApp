import 'package:cloud_firestore/cloud_firestore.dart';

class QueryModel {
  final String id;
  final String description;
  final String postedByUid;
  final String postedByName;
  final bool postedByIsInsider;
  final bool postedByIsPremium;
  final DateTime postedAt;
  final int responseCount;
  final bool isResolved;
  final String? imagePath;
  final DateTime? expiresAt;

  QueryModel({
    required this.id,
    required this.description,
    required this.postedByUid,
    required this.postedByName,
    this.postedByIsInsider = false,
    this.postedByIsPremium = false,
    required this.postedAt,
    required this.responseCount,
    required this.isResolved,
    this.imagePath,
    this.expiresAt,
  });

  factory QueryModel.fromMap(Map<String, dynamic> map, String docId) {
    final postedBy = Map<String, dynamic>.from(map['postedBy'] as Map);
    return QueryModel(
      id: docId,
      description: map['description'] ?? '',
      postedByUid: postedBy['uid'] ?? '',
      postedByName: postedBy['name'] ?? '',
      postedByIsInsider: postedBy['isInsider'] ?? false,
      postedByIsPremium: postedBy['isPremium'] ?? false,
      postedAt: (map['postedAt'] as Timestamp).toDate(),
      responseCount: int.parse(map['responseCount'].toString()),
      isResolved: map['isResolved'] ?? false,
      imagePath: map['imagePath'] as String?,
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  QueryModel copyWith({
    String? id,
    String? description,
    String? postedByUid,
    String? postedByName,
    bool? postedByIsInsider,
    bool? postedByIsPremium,
    DateTime? postedAt,
    int? responseCount,
    bool? isResolved,
    String? imagePath,
    DateTime? expiresAt,
  }) {
    return QueryModel(
      id: id ?? this.id,
      description: description ?? this.description,
      postedByUid: postedByUid ?? this.postedByUid,
      postedByName: postedByName ?? this.postedByName,
      postedByIsInsider: postedByIsInsider ?? this.postedByIsInsider,
      postedByIsPremium: postedByIsPremium ?? this.postedByIsPremium,
      postedAt: postedAt ?? this.postedAt,
      responseCount: responseCount ?? this.responseCount,
      isResolved: isResolved ?? this.isResolved,
      imagePath: imagePath ?? this.imagePath,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
