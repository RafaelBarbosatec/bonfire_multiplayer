import 'package:bonfire_multiplayer/pages/characters/character_select_page.dart';
import 'package:flutter/material.dart';

class CharacterSelectRoute {
  static const name = '/characters';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const CharacterSelectPage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      name,
      (route) => false,
    );
  }
}
