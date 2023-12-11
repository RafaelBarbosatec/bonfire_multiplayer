import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/websocket/polo_websocket.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/home/bloc/home_bloc.dart';
import 'package:bonfire_multiplayer/pages/home/home_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // String address = '192.168.0.10';
    String address = '127.0.0.1';
    // String address = '10.0.2.2';
    return MultiProvider(
      providers: [
        Provider<WebsocketProvider>(
          create: (context) => PoloWebsocket(address: address),
        ),
        Provider(
          create: (context) => GameEventManager(websocket: context.read()),
        ),
        BlocProvider(create: (context) => HomeBloc(context.read()))
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routes: {
          ...HomeRoute.builder,
          ...GameRoute.builder,
        },
      ),
    );
  }
}
