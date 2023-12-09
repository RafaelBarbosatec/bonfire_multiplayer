import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  final GameEventManager _eventManager;
  MyPlayerBloc(this._eventManager) : super(MyPlayerState()) {
    on<UpdateMoveStateEvent>(_onUpdateMoveStateEvent);
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    _eventManager.send(
      EventType.PLAYER_MOVE.name,
      MoveEvent(
        position: event.position.toGamePosition(),
        time: DateTime.now().toIso8601String(),
        direction: event.direction?.name,
      ),
    );
  }
}
