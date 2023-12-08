import 'package:bonfire/bonfire.dart';
import 'package:bonfire_multiplayer/components/my_player/bloc/my_player_bloc.dart';
import 'package:bonfire_multiplayer/components/my_player/my_player.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Game extends StatelessWidget {
  static const tileSize = 16.0;
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPlayerBloc(context.read()),
      child: BonfireWidget(
        map: WorldMapByTiled('map/map.tmj'),
        joystick: Joystick(
          keyboardConfig: KeyboardConfig(
            enableDiagonalInput: false,
          ),
          directional: JoystickDirectional(
            enableDiagonalInput: false,
          ),
        ),
        player: MyPlayer(
          position: Vector2(8 * tileSize, 7 * tileSize),
          skin: PayerSkin.boy,
        ),
        cameraConfig: CameraConfig(
          initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
          moveOnlyMapArea: true,
        ),
      ),
    );
  }
}
