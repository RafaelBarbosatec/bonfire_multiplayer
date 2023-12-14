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
    on<MoveResponseEvent>(_onMoveResponseEvent);
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    _eventManager.send(
      EventType.PLAYER_MOVE.name,
      MoveEvent(
        time: DateTime.now().toIso8601String(),
        direction: event.direction?.name ?? '',
      ),
    );
  }

  FutureOr<void> _onMoveResponseEvent(
    MoveResponseEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    if (event.success) {
      // The move was successful
      // Fire an event to update the player's position
      add(UpdatePlayerPositionEvent(position: event.position!));
    } else {
      // The move was not successful
      // Handle the error here
    }
  }
}

class UpdatePlayerPositionEvent extends MyPlayerEvent {
  final Vector2 position;

  UpdatePlayerPositionEvent({required this.position});
}
