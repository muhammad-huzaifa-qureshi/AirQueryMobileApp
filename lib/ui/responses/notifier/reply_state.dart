class ReplyState {
  final String? replyToUid;
  final String? replyToName;

  const ReplyState({this.replyToUid, this.replyToName});

  bool get isReplying => replyToUid != null;

  ReplyState copyWith({String? replyToUid, String? replyToName}) {
    return ReplyState(
      replyToUid: replyToUid ?? this.replyToUid,
      replyToName: replyToName ?? this.replyToName,
    );
  }

  ReplyState clear() => const ReplyState();
}
