import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  final GameEventManager _eventManager;
  final String id;
  final Vector2 initPosition;
  final String mapId;
  MyPlayerBloc(this._eventManager, this.id, this.initPosition, this.mapId)
      : super(MyPlayerState(
          position: initPosition,
          direction: MoveDirectionEnum.down,
          lastDirection: MoveDirectionEnum.down,
        )) {
    on<UpdateMoveStateEvent>(_onUpdateMoveStateEvent);
    on<UpdatePlayerPositionEvent>(_onUpdatePlayerPositionEvent);

    _eventManager.onSpecificPlayerState(
      id,
      _onPlayerState,
    );
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    _eventManager.send(
      EventType.MOVE.name,
      MoveEvent(
        position: event.position.toGamePosition(),
        time: DateTime.now().toIso8601String(),
        direction: event.direction,
        mapId: mapId,
      ),
    );
  }

  void _onPlayerState(ComponentStateModel state) => add(
        UpdatePlayerPositionEvent(
          position: state.position.toVector2(),
          direction: state.direction,
          lastDirection: state.lastDirection,
        ),
      );

  FutureOr<void> _onUpdatePlayerPositionEvent(
    UpdatePlayerPositionEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    emit(
      state.copyWith(
        position: event.position,
        direction: event.direction,
        lastDirection: event.lastDirection,
      ),
    );
  }
}
