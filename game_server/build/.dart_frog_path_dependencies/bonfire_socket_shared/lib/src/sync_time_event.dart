// ignore_for_file: public_member_api_docs

import 'package:bonfire_socket_shared/src/event.dart';

class PingSyncTimeEvent extends BEvent {
  PingSyncTimeEvent()
      : super(
          event: eventName,
          time: DateTime.now().microsecondsSinceEpoch,
          data: null,
        );
  static const String eventName = 'ping_sync_time';
}

class PongSyncTimeEvent extends BEvent {
  PongSyncTimeEvent()
      : super(
          event: eventName,
          time: DateTime.now().microsecondsSinceEpoch,
          data: null,
        );
  static const String eventName = 'pong_sync_time';
}
