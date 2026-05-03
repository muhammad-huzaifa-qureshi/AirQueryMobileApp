import 'package:cloud_firestore/cloud_firestore.dart';

class ResponseModel {
  final String id;
  final String description;
  final String postedByUid;
  final String postedByName;
  final bool postedByIsInsider;
  final bool postedByIsPremium;
  final DateTime postedAt;
  final String? mentionedUid;
  final String? mentionedName;

  ResponseModel({
    required this.id,
    required this.description,
    required this.postedByUid,
    required this.postedByName,
    this.postedByIsInsider = false,
    this.postedByIsPremium = false,
    required this.postedAt,
    this.mentionedUid,
    this.mentionedName,
  });

  factory ResponseModel.fromMap(Map<String, dynamic> map, String docId) {
    final postedBy = Map<String, dynamic>.from(map['postedBy'] as Map);
    return ResponseModel(
      id: docId,
      description: map['description'] ?? '',
      postedByUid: postedBy['uid'] ?? '',
      postedByName: postedBy['name'] ?? '',
      postedByIsInsider: postedBy['isInsider'] ?? false,
      postedByIsPremium: postedBy['isPremium'] ?? false,
      postedAt: (map['postedAt'] as Timestamp).toDate(),
      mentionedUid: map['mentionedUid'] as String?,
      mentionedName: map['mentionedName'] as String?,
    );
  }

  bool get hasMention =>
      mentionedUid != null && mentionedName != null && mentionedName!.isNotEmpty;
}
