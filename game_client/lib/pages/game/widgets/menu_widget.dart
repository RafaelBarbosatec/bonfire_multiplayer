import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_multiplayer/pages/game/game_page.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  static const overlayName = 'MenuWidget';
  final BonfireGameInterface game;
  const MenuWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final maxZoom = getZoomFromMaxVisibleTile(context, GamePage.tileSize, 20);
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _plusZoom(context, maxZoom),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () => _minusZoom(context, maxZoom),
                      icon: const Icon(Icons.remove),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showExitDialog(context),
                  icon: const Icon(Icons.exit_to_app),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _plusZoom(BuildContext context, double minZoom) {
    final currentZoom = game.camera.zoom;
    final newZoom = (currentZoom + 0.1).clamp(minZoom, minZoom * 2);
    game.camera.zoom = newZoom;
  }

  void _minusZoom(BuildContext context, double minZoom) {
    final currentZoom = game.camera.zoom;
    final newZoom = (currentZoom - 0.1).clamp(minZoom, minZoom * 2);
    game.camera.zoom = newZoom;
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit Game'),
          content: const Text('Are you sure you want to exit the game?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                inject<WebsocketProvider>().disconnect(1000);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
