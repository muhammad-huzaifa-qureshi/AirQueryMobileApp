class MentionState {
  final String? mentionToUid;
  final String? mentionToName;

  const MentionState({this.mentionToUid, this.mentionToName});

  bool get isMentioning => mentionToUid != null;

  MentionState copyWith({String? mentionToUid, String? mentionToName}) {
    return MentionState(
      mentionToUid: mentionToUid ?? this.mentionToUid,
      mentionToName: mentionToName ?? this.mentionToName,
    );
  }

  MentionState clear() => const MentionState();
}
