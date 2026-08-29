import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/input_event.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  final GameEventManager _eventManager;
  final ComponentStateModel initialState;
  final String mapId;

  /// Sequential id generator for client-side prediction inputs.
  int _inputCounter = 0;

  /// Buffer of inputs sent but not yet confirmed by the server
  /// (`server.lastInputId` < input.id). While non-empty, the server is
  /// behind (lag) and the client must NOT correct its predicted position.
  final List<InputEvent> _pendingInputs = [];

  /// Safety bound: never grow the buffer forever (e.g. connection stalls).
  static const int _maxPendingInputs = 30;

  MyPlayerBloc(this._eventManager, this.initialState, this.mapId)
      : super(MyPlayerState(
          position: initialState.position.toVector2(),
          direction: initialState.direction,
          lastDirection: initialState.lastDirection ?? MoveDirectionEnum.down,
        )) {
    on<UpdateMoveStateEvent>(_onUpdateMoveStateEvent);
    on<UpdatePlayerPositionEvent>(_onUpdatePlayerPositionEvent);

    _eventManager.onSpecificPlayerState(
      initialState.id,
      _onPlayerState,
    );
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    final inputId = ++_inputCounter;

    // Keep the input in the prediction buffer until the server confirms it.
    _pendingInputs.add(
      InputEvent(
        id: inputId,
        direction: event.direction,
        timestamp: DateTime.now(),
        position: event.position,
      ),
    );
    if (_pendingInputs.length > _maxPendingInputs) {
      _pendingInputs.removeAt(0);
    }

    _eventManager.send(
      EventType.MOVE.name,
      MoveEvent(
        position: event.position.toGamePosition(),
        time: DateTime.now().toIso8601String(),
        direction: event.direction,
        mapId: mapId,
        inputId: inputId,
      ),
    );
  }

  void _onPlayerState(ComponentStateModel state) => add(
        UpdatePlayerPositionEvent(
          position: state.position.toVector2(),
          direction: state.direction,
          lastDirection: state.lastDirection,
          lastInputId: state.lastInputId,
        ),
      );

  FutureOr<void> _onUpdatePlayerPositionEvent(
    UpdatePlayerPositionEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    // Reconciliation: drop inputs the server has already processed.
    if (event.lastInputId != null) {
      _pendingInputs.removeWhere((input) => input.id <= event.lastInputId!);
    }

    emit(
      state.copyWith(
        position: event.position,
        direction: event.direction,
        lastDirection: event.lastDirection,
        lastInputId: event.lastInputId,
        hasPendingInputs: _pendingInputs.isNotEmpty,
      ),
    );
  }
}
