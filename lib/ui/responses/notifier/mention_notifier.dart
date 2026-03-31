import 'package:air_query/ui/responses/notifier/mention_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mentionStateProvider =
    NotifierProvider.autoDispose<MentionNotifier, MentionState>(MentionNotifier.new);

class MentionNotifier extends Notifier<MentionState> {
  @override
  MentionState build() {
    return MentionState();
  }

  void setMention(String uid, String name) {
    state = state.copyWith(mentionToUid: uid, mentionToName: name);
  }

  void clearMention() {
    state = const MentionState();
  }
}
