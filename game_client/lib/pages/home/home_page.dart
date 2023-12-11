import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:bonfire_multiplayer/pages/game/game_route.dart';
import 'package:bonfire_multiplayer/pages/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;
  late HomeBloc _bloc;
  @override
  void initState() {
    _controller = TextEditingController();
    Future.delayed(Duration.zero, init);
    super.initState();
  }

  void init() {
    _bloc = context.read<HomeBloc>();
    _bloc.add(ConnectEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.ackEvent != null) {
          GameRoute.open(context, state.ackEvent!);
        }
      },
      builder: (context, state) {
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
                      _buildItem(
                          PayerSkin.boy, state.skinSelected, _selectSkin),
                      _buildItem(
                          PayerSkin.girl, state.skinSelected, _selectSkin),
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
                      onPressed: state.connected ? _enter : null,
                      child: const Text('Enter'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.connected ? 'Connected' : 'Connecting',
                    style: TextStyle(
                      color: state.connected ? Colors.green : Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _enter() {
    if (_controller.text.isNotEmpty) {
      _bloc.add(JoinGameEvent(name: _controller.text));
    }
  }

  Widget _buildItem(
    PayerSkin skin,
    PayerSkin skinSlected,
    ValueChanged<PayerSkin> onTap,
  ) {
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
    _bloc.add(SelectSkinEvent(skin: value));
  }
}
