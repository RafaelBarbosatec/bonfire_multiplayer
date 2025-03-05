import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  static const overlayName = 'MenuWidget';
  const MenuWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.exit_to_app),
              )
            ],
          ),
        ),
      ),
    );
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
