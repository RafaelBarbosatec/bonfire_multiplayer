import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/my_remote_player.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/main.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

class GamePage extends StatefulWidget {
  final JoinAckEvent event;
  static const tileSize = 16.0;
  const GamePage({super.key, required this.event});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameEventManager _eventManager;
  late BonfireGameInterface game;

  @override
  void dispose() {
    _eventManager.removeOnPlayerState(_onPlayerState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPlayerBloc(
        context.read(),
        widget.event.state.id,
        widget.event.state.position.toVector2(),
        widget.event.map.name,
      ),
      child: BonfireWidget(
        map: WorldMapByTiled('http://$address:8080/${widget.event.map.path}'),
        joystick: Joystick(
          keyboardConfig: KeyboardConfig(
            enableDiagonalInput: false,
          ),
          directional: JoystickDirectional(
            enableDiagonalInput: false,
          ),
        ),
        player: _getPlayer(widget.event.state),
        components: _getComponents(widget.event, context),
        cameraConfig: CameraConfig(
          initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
          moveOnlyMapArea: true,
        ),
        onReady: _onReady,
      ),
    );
  }

  // Adds player in the game with ack informations
  Player _getPlayer(ComponentStateModel state) {
    return MyPlayer(
      position: state.position.toVector2(),
      skin: PayerSkin.fromName(state.properties['skin']),
      name: state.name,
      speed: state.speed,
    );
  }

  // Adds remote plasyers with ack informations
  List<GameComponent> _getComponents(JoinAckEvent event, BuildContext context) {
    return event.players.map((e) {
      return _createRemotePlayer(e);
    }).toList();
  }

  int lastServerRemotes = 0;

  // When the game is ready init listeners:
  // PLAYER_LEAVE: When some player leave remove it of game.
  // PLAYER_JOIN: When some player enter adds it in the game.
  void _onReady(BonfireGameInterface game) {
    this.game = game;
    _eventManager = context.read();
    _eventManager.onDisconnect(() {
      HomeRoute.open(context);
    });

    _eventManager.onPlayerState(
      _onPlayerState,
    );
    _eventManager.onEvent<JoinAckEvent>(
      EventType.JOIN_ACK.name,
      _onAckJoint,
    );
  }

  void _onPlayerState(Iterable<ComponentStateModel> serverPlayers) {
    if (lastServerRemotes != serverPlayers.length) {
      final remotePlayers = game.query<MyRemotePlayer>();
      // adds RemotePlayer if no exist in the game but exist in server
      for (var serverPlayer in serverPlayers) {
        if (serverPlayer.id != widget.event.state.id) {
          final contain = remotePlayers.any(
            (element) => element.id == serverPlayer.id,
          );
          if (!contain) {
            game.add(
              _createRemotePlayer(serverPlayer),
            );
          }
        }
      }

      // remove RemotePlayer if no exist in server
      for (var player in remotePlayers) {
        final contain = serverPlayers.any(
          (element) => element.id == player.id,
        );
        if (!contain) {
          player.removeFromParent();
        }
      }
      lastServerRemotes = serverPlayers.length;
    }
  }

  GameComponent _createRemotePlayer(ComponentStateModel state) {
    return MyRemotePlayer(
      position: state.position.toVector2(),
      skin: PayerSkin.fromName(state.properties['skin']),
      eventManager: context.read(),
      id: state.id,
      name: state.name,
      speed: state.speed,
    );
  }

  void _onAckJoint(JoinAckEvent event) {
    GameRoute.open(context, event);
  }
}
