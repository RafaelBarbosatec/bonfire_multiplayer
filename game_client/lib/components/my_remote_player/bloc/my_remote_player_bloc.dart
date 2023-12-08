import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/data/my_websocket.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_remote_player_event.dart';
part 'my_remote_player_state.dart';

class MyRemotePlayerBloc
    extends Bloc<MyRemotePlayerEvent, MyRemotePlayerState> {
  final MyWebsocket _websocket;
  final String playerId;
  final Vector2 initPosition;
  MyRemotePlayerBloc( this.playerId, this.initPosition,this._websocket)
      : super(MyRemotePlayerState(position: initPosition)) {
    // _websocket.onEvent('', (data) {});
  }
}
