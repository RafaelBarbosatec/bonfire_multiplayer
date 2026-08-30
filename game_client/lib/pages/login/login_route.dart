import 'package:bonfire_multiplayer/pages/login/login_page.dart';
import 'package:flutter/material.dart';

class LoginRoute {
  static const name = '/';

  static Map<String, WidgetBuilder> get builder => {
        name: (context) => const LoginPage(),
      };

  static Future open(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      name,
      (route) => false,
    );
  }
}
