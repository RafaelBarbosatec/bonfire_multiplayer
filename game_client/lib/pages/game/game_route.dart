import 'package:bonfire_multiplayer/pages/game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_events/shared_events.dart';

class GameRoute {
  static const name = '/game';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => GamePage(
              event: ModalRoute.of(context)?.settings.arguments as JoinAckEvent,
            ),
      };

  static Future open(BuildContext context, JoinAckEvent event) {
    return Navigator.of(context).pushNamed(name, arguments: event);
  }
}
