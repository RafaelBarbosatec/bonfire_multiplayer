import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/components/my_remote_enemy/my_remote_enemy.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/my_remote_player.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

class GamePage extends StatefulWidget {
  final JoinMapEvent event;
  const GamePage({super.key, required this.event});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late GameEventManager _eventManager;
  BonfireGameInterface? game;
  late AnimationController _controller;
  late JoinMapEvent joinMapEvent;

  @override
  void initState() {
    _eventManager = inject();
    joinMapEvent = widget.event;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void dispose() {
    _eventManager.removeOnPlayerState(_onPlayerState);
    _eventManager.removeOnPlayerState(_onEnemyState);
    _eventManager.onJoinMapEvent(null);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(joinMapEvent.map.path),
      color: Colors.black,
      child: FadeTransition(
        opacity: _controller,
        child: BonfireWidget(
          map: WorldMapByTiled(
            WorldMapReader.fromNetwork(
              Uri.parse(
                '${BootstrapInjector.enviroment.restAddress}/${joinMapEvent.map.path}',
              ),
            ),
          ),
          playerControllers: [
            Joystick(
              directional: JoystickDirectional(
                enableDiagonalInput: false,
              ),
            ),
            Keyboard(
              config: KeyboardConfig(
                enableDiagonalInput: false,
              ),
            )
          ],
          player: MyPlayer(
            state: joinMapEvent.state,
            eventManager: _eventManager,
            mapId: joinMapEvent.map.id,
          ),
          components: _getComponents(joinMapEvent, context),
          cameraConfig: CameraConfig(
            initialMapZoomFit: InitialMapZoomFitEnum.fitWidth,
            moveOnlyMapArea: true,
          ),
          onReady: _onReady,
        ),
      ),
    );
  }

  // Adds remote plasyers with ack informations
  List<GameComponent> _getComponents(JoinMapEvent event, BuildContext context) {
    return event.players.map((e) {
      return _createRemotePlayer(e);
    }).toList();
  }

  int lastServerRemotes = 0;
  int lastNpcServerRemotes = 0;

  // When the game is ready init listeners:
  // PLAYER_LEAVE: When some player leave remove it of game.
  // PLAYER_JOIN: When some player enter adds it in the game.
  void _onReady(BonfireGameInterface game) {
    this.game = game;
    _eventManager.onDisconnect(_onDisconnect);

    _eventManager.onPlayerState(
      _onPlayerState,
    );

    _eventManager.onEnemyState(
      _onEnemyState,
    );

    _eventManager.onJoinMapEvent(_onJoinMap);
    _onPlayerState(joinMapEvent.players);
    _onEnemyState(joinMapEvent.npcs);
    Future.delayed(const Duration(milliseconds: 100), _controller.forward);
  }

  void _onPlayerState(Iterable<ComponentStateModel> serverPlayers) {
    if (lastServerRemotes != serverPlayers.length && game != null) {
      final remotePlayers = game?.query<MyRemotePlayer>() ?? [];
      // adds RemotePlayer if no exist in the game but exist in server
      for (var serverPlayer in serverPlayers) {
        if (serverPlayer.id != joinMapEvent.state.id) {
          final contain = remotePlayers.any(
            (element) => element.id == serverPlayer.id,
          );
          if (!contain) {
            game?.add(
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

  void _onEnemyState(Iterable<ComponentStateModel> serverEnemies) {
    if (lastNpcServerRemotes != serverEnemies.length && game != null) {
      lastNpcServerRemotes = serverEnemies.length;
      final remotePlayers = game?.query<MyRemoteEnemy>() ?? [];
      // adds RemotePlayer if no exist in the game but exist in server
      for (var serverPlayer in serverEnemies) {
        if (serverPlayer.id != joinMapEvent.state.id) {
          final contain = remotePlayers.any(
            (element) => element.id == serverPlayer.id,
          );
          if (!contain) {
            game?.add(
              _createRemoteEnemy(serverPlayer),
            );
          }
        }
      }

      // remove RemotePlayer if no exist in server
      for (var player in remotePlayers) {
        final contain = serverEnemies.any(
          (element) => element.id == player.id,
        );
        if (!contain) {
          player.removeFromParent();
        }
      }
    }
  }

  GameComponent _createRemotePlayer(ComponentStateModel state) {
    return MyRemotePlayer(
      position: state.position.toVector2(),
      initDirection: state.lastDirection?.toDirection(),
      skin: PlayerSkin.fromName(state.properties['skin']),
      eventManager: _eventManager,
      id: state.id,
      name: state.name,
      speed: state.speed,
    );
  }

  GameComponent _createRemoteEnemy(ComponentStateModel state) {
    return MyRemoteEnemy(
      position: state.position.toVector2(),
      initDirection: state.lastDirection?.toDirection(),
      skin: PlayerSkin.fromName(state.properties['skin']),
      eventManager: _eventManager,
      id: state.id,
      name: state.name,
      speed: state.speed,
    );
  }

  Future<void> _onJoinMap(JoinMapEvent event) async {
    game = null;
    lastNpcServerRemotes = 0;
    lastServerRemotes = 0;
    _controller.value = 0.0;
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {
        joinMapEvent = event;
      });
    }
  }

  Future<void> _onDisconnect() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      HomeRoute.open(context);
    }
  }
}
