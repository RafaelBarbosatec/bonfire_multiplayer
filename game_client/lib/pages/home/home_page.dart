import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;
  late GameEventManager _eventManager;
  bool connected = false;
  PayerSkin skinSlected = PayerSkin.boy;
  @override
  void initState() {
    _controller = TextEditingController();
    Future.delayed(Duration.zero, _startWebSocket);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: [
                  _buildItem(PayerSkin.boy, skinSlected, _selectSkin),
                  _buildItem(PayerSkin.girl, skinSlected, _selectSkin),
                ],
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: connected ? _enter : null,
                  child: const Text('Enter'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                connected ? 'Connected' : 'Connecting',
                style: TextStyle(
                  color: connected ? Colors.green : Colors.yellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWebSocket() async {
    final websocket = context.read<WebsocketProvider>();
    await websocket.init(
      onConnect: _onConnect,
      onDisconnect: _onDisconnect,
    );
  }

  void _onConnect() {
    _eventManager = context.read();
    _eventManager.onEvent<JoinAckEvent>(EventType.JOIN_ACK.name, (event) {
      GameRoute.open(context, event);
    });
    setState(() {
      connected = true;
    });
  }

  void _onDisconnect() {
    setState(() {
      connected = false;
    });
  }

  void _enter() {
    if (_controller.text.isNotEmpty) {
      _eventManager.send(
        EventType.JOIN.name,
        JoinEvent(name: _controller.text, skin: skinSlected.name),
      );
    }
  }

  Widget _buildItem(
      PayerSkin skin, PayerSkin skinSlected, ValueChanged<PayerSkin> onTap) {
    return FutureBuilder(
      future: Sprite.load(
        skin.path,
        srcSize: Vector2.all(32),
        srcPosition: Vector2(0, 32),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        return Card(
          color: skin == skinSlected ? Colors.green : null,
          child: InkWell(
            onTap: () => onTap.call(skin),
            child: Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(16),
              child: snapshot.data!.asWidget(),
            ),
          ),
        );
      },
    );
  }

  void _selectSkin(PayerSkin value) {
    setState(() {
      skinSlected = value;
    });
  }
}
