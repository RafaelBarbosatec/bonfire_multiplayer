// ignore_for_file: public_member_api_docs

import 'package:bonfire_socket_shared/src/event.dart';

class BSyncTimeEvent extends BEvent {
  BSyncTimeEvent()
      : super(
          event: eventName,
          time: DateTime.now().microsecondsSinceEpoch,
          data: null,
        );
  static const String eventName = 'socket_sync_time';
}
