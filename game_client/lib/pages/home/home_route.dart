import 'package:bonfire_multiplayer/pages/home/home_page.dart';
import 'package:flutter/material.dart';

class HomeRoute {
  static const name = '/';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const HomePage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      name,
      (route) => false,
    );
  }
}
