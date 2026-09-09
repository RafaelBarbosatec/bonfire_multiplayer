import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/components/attack_effect_renderer.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/components/my_remote_enemy/my_remote_enemy.dart';
import 'package:bonfire_multiplayer/components/my_remote_player/my_remote_player.dart';
import 'package:bonfire_multiplayer/data/auth/auth_session.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/pages/characters/character_select_route.dart';
import 'package:bonfire_multiplayer/pages/game/widgets/menu_widget.dart';
import 'package:bonfire_multiplayer/pages/game/widgets/player_stats_dialog.dart';
import 'package:bonfire_multiplayer/pages/game/widgets/player_status_widget.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:bonfire_multiplayer/util/extensions.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

class GamePage extends StatefulWidget {
  static const tileSize = 16.0;
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

  /// Latest server snapshot of our own player, feeding the status HUD.
  /// Only replaced when the attributes actually change, so the HUD doesn't
  /// rebuild on every movement tick (position updates are irrelevant here).
  final ValueNotifier<ComponentStateModel?> _ownState =
      ValueNotifier<ComponentStateModel?>(null);

  @override
  void initState() {
    _eventManager = inject();
    joinMapEvent = widget.event;
    _ownState.value = widget.event.state;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  void dispose() {
    _eventManager.removeOnPlayerState(_onPlayerState);
    _eventManager.removeOnEnemyState(_onEnemyState);
    _eventManager.removeOnRemoved(_onRemoved);
    _eventManager.onDamageEvent(null);
    _eventManager.onAttackEffectEvent(null);
    _eventManager.onJoinMapEvent(null);
    _ownState.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      key: Key(joinMapEvent.map.path),
      color: Colors.black,
      child: Stack(
        children: [
          const Center(
            child: Text(
              'Loading map...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FadeTransition(
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
                  directional: JoystickDirectional(enableDiagonalInput: false),
                  actions: [
                    JoystickAction(
                      actionId: 'attack',
                      color: const Color(0xE0E05545),
                      size: 64,
                      margin: const EdgeInsets.only(bottom: 100, right: 28),
                    ),
                  ],
                ),
                Keyboard(config: KeyboardConfig(enableDiagonalInput: false)),
              ],
              player: MyPlayer(
                state: joinMapEvent.state,
                eventManager: _eventManager,
                mapId: joinMapEvent.map.id,
              ),
              components: _getComponents(joinMapEvent, context),
              cameraConfig: CameraConfig(
                moveOnlyMapArea: true,
                zoom: getZoomFromMaxVisibleTile(context, GamePage.tileSize, 20),
              ),
              onReady: _onReady,
              overlayBuilderMap: {
                PlayerStatusWidget.overlayName: (context, gameRef) {
                  return ValueListenableBuilder<ComponentStateModel?>(
                    valueListenable: _ownState,
                    builder: (context, state, _) {
                      final s = state ?? joinMapEvent.state;
                      return PlayerStatusWidget(
                        attributes: s.attributes ?? const PlayerAttributes(),
                        name: s.name,
                        skinPath: PlayerSkin.fromName(
                          s.properties['skin'],
                        ).path,
                        onOpenStatus: () => _openStatsDialog(context),
                      );
                    },
                  );
                },
                MenuWidget.overlayName: (context, gameRef) {
                  return MenuWidget(game: gameRef);
                },
              },
              initialActiveOverlays: const [
                PlayerStatusWidget.overlayName,
                MenuWidget.overlayName,
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Adds remote plasyers with ack informations
  List<GameComponent> _getComponents(JoinMapEvent event, BuildContext context) {
    List<GameComponent> components = [];

    components.addAll(event.players.map((e) => _createRemotePlayer(e)));
    components.addAll(event.npcs.map((e) => _createRemoteEnemy(e)));

    return components;
  }

  // When the game is ready init listeners:
  // Handles player/npc state updates and removals
  void _onReady(BonfireGameInterface game) {
    this.game = game;
    _eventManager.onDisconnect(_onDisconnect);

    _eventManager.onPlayerState(_onPlayerState);
    _eventManager.onEnemyState(_onEnemyState);
    _eventManager.onRemoved(_onRemoved);
    _eventManager.onDamageEvent(_onDamageEvent);
    _eventManager.onAttackEffectEvent(_onAttackEffectEvent);
    _eventManager.onJoinMapEvent(_onJoinMap);

    Future.delayed(const Duration(milliseconds: 100), _controller.forward);
  }

  void _onPlayerState(Iterable<ComponentStateModel> serverPlayers) {
    if (game == null) return;

    final remotePlayers = game?.query<MyRemotePlayer>() ?? [];

    for (var serverPlayer in serverPlayers) {
      // Our own updates feed the status HUD (HP/SP/EXP/level) and are never
      // turned into a remote entity.
      if (serverPlayer.id == joinMapEvent.state.id) {
        _updateOwnState(serverPlayer);
        continue;
      }
      // Add new players that don't exist locally
      final exists = remotePlayers.any(
        (element) => element.id == serverPlayer.id,
      );
      if (!exists) {
        game?.add(_createRemotePlayer(serverPlayer));
      }
    }
    // Note: Removals are now handled by _onRemoved
  }

  /// Keeps the HUD snapshot fresh: replaces the value only when the server
  /// attributes actually changed (avoids rebuilding on every move tick).
  void _updateOwnState(ComponentStateModel serverPlayer) {
    final current = _ownState.value;
    if (current == null || current.attributes != serverPlayer.attributes) {
      _ownState.value = serverPlayer;
    }
  }

  List<String> addedIds = [];

  void _onEnemyState(Iterable<ComponentStateModel> serverEnemies) {
    if (game == null) return;

    // Add new NPCs that don't exist locally. The existence check re-queries
    // the live component list on EVERY iteration (instead of capturing it
    // once before the loop) so that two states sharing the same id in a
    // single delta (e.g. a not-yet-removed corpse + its respawn) never create
    // two overlapping enemies with the same id.
    for (var serverEnemy in serverEnemies) {
      final exists = game?.query<MyRemoteEnemy>().any(
                (element) => element.id == serverEnemy.id,
              ) ??
          false;
      if (!exists && !addedIds.contains(serverEnemy.id)) {
        addedIds.add(serverEnemy.id);
        game?.add(_createRemoteEnemy(serverEnemy));
      }
    }

    // Note: Removals are now handled by _onRemoved
  }

  /// Plays an attack effect broadcast by the server at the exact world
  /// position the server sent. Effect ids this client doesn't know are
  /// silently ignored (nothing is rendered).
  void _onAttackEffectEvent(AttackEffectEvent event) {
    final currentGame = game;
    if (currentGame == null) return;
    renderAttackEffect(currentGame, event);
  }

  /// Shows a floating damage number over the damaged entity when it is
  /// currently visible on this client (bonfire's built-in damage text).
  void _onDamageEvent(DamageEvent damage) {
    final currentGame = game;
    if (currentGame == null) return;

    MyRemoteEnemy? target;
    for (final enemy in currentGame.query<MyRemoteEnemy>()) {
      if (enemy.id == damage.targetId) {
        target = enemy;
        break;
      }
    }
    if (target == null || target.isRemoving) return;

    target.util.showDamage(
      damage.damage.toDouble(),
      config: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFE9A8),
        shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
      ),
    );
  }

  /// Handle entity removals (both players and NPCs)
  void _onRemoved(List<String> removedIds) {
    if (game == null || removedIds.isEmpty) return;
    addedIds.removeWhere((id) => removedIds.contains(id));

    // Remove players with matching IDs
    final remotePlayers = game?.query<MyRemotePlayer>() ?? [];
    for (var player in remotePlayers) {
      if (removedIds.contains(player.id)) {
        player.removeFromParent();
      }
    }

    // Remove NPCs with matching IDs
    final remoteEnemies = game?.query<MyRemoteEnemy>() ?? [];
    for (var enemy in remoteEnemies) {
      if (removedIds.contains(enemy.id)) {
        enemy.removeFromParent();
      }
    }
  }

  GameComponent _createRemotePlayer(ComponentStateModel state) {
    return MyRemotePlayer(
      position: state.position.toVector2(),
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
      life: state.life.toDouble(),
      maxLife: state.maxLife.toDouble(),
    );
  }

  Future<void> _onJoinMap(JoinMapEvent event) async {
    game = null;
    _controller.value = 0.0;
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {
        joinMapEvent = event;
        _ownState.value = event.state;
      });
    }
  }

  Future<void> _onDisconnect() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      if (AuthSession.instance.isLogged) {
        CharacterSelectRoute.open(context);
      } else {
        HomeRoute.open(context);
      }
    }
  }

  /// Opens the Ragnarok-style Status dialog (base stats + derived stats).
  Future<void> _openStatsDialog(BuildContext context) {
    return showPlayerStatsDialog(
      context,
      ownState: _ownState,
      onAllocateStat: _sendAllocateStat,
    );
  }

  /// Sends a server-authoritative stat investment. The result comes back in
  /// the regular state delta (see `Player.allocateStat`).
  void _sendAllocateStat(String stat) {
    _eventManager.send(
      EventType.ALLOCATE_STAT.name,
      AllocateStatEvent(stat: stat),
    );
  }
}
