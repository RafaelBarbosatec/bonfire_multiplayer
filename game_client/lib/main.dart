import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/pages/characters/character_select_route.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:bonfire_multiplayer/pages/login/login_route.dart';
import 'package:bonfire_multiplayer/util/my_page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The game is designed to be played in landscape (Ragnarok-style).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  BootstrapInjector.run();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: MyPageTransition(),
            TargetPlatform.iOS: MyPageTransition(),
            TargetPlatform.macOS: MyPageTransition(),
          },
        ),
      ),
      routes: {
        ...LoginRoute.builder,
        ...CharacterSelectRoute.builder,
        ...HomeRoute.builder,
        ...GameRoute.builder,
      },
    );
  }
}
