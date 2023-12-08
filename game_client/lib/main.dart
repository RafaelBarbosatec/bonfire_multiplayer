import 'package:bonfire_multiplayer/data/my_websocket.dart';
import 'package:bonfire_multiplayer/pages/game/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

late MyWebsocket myWebsocket;

void main() async {
  String address = '127.0.0.1';
  // String addressAndroidEmulator = '10.0.2.2';
  myWebsocket = MyWebsocket(address: address);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => myWebsocket,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const Game(),
      ),
    );
  }
}
