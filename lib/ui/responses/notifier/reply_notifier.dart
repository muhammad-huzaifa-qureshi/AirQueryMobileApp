import 'package:air_query/ui/responses/notifier/reply_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final replyStateProvider =
    NotifierProvider.autoDispose<ReplyNotifier, ReplyState>(ReplyNotifier.new);

class ReplyNotifier extends Notifier<ReplyState> {
  @override
  ReplyState build() {
    return ReplyState();
  }

  void setReply(String uid, String name) {
    state = state.copyWith(replyToUid: uid, replyToName: name);
  }

  void clearReply() {
    state = const ReplyState();
  }
}
