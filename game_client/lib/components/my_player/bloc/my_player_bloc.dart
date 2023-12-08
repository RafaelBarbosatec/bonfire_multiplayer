import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/my_websocket.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  final MyWebsocket _websocket;
  MyPlayerBloc(this._websocket) : super(MyPlayerState()) {
    on<UpdateMoveStateEvent>(_onUpdateMoveStateEvent);
  }

  FutureOr<void> _onUpdateMoveStateEvent(
    UpdateMoveStateEvent event,
    Emitter<MyPlayerState> emit,
  ) {
    print(event.position);
    // _websocket.send(event, data)
  }
}
