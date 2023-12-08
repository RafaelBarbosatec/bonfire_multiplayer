import 'package:bonfire_multiplayer/main.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _startWebSocket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Enter'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _startWebSocket() async {
    await myWebsocket.init(
      onConnect: _onConnect,
      onDisconnect: _onDisconnect,
    );
  }

  void _onConnect() {
    setState(() {});
  }

  void _onDisconnect() {
    setState(() {});
  }
}
