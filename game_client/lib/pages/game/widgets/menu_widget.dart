import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  static const overlayName = 'MenuWidget';
  final GameEventManager eventManager;
  const MenuWidget({super.key, required this.eventManager});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              // eventManager.disconnect();
              // await Future.delayed(Durations.medium2);
              HomeRoute.open(context);
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
    );
  }
}
