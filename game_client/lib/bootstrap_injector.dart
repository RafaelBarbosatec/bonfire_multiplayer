import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/websocket/bonfire_websocket.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_multiplayer/pages/home/bloc/home_bloc.dart';
import 'package:bonfire_multiplayer/util/enviroment.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class BootstrapInjector {
  static BaseInviroment enviroment = LocalInviroment();
  // static  BaseInviroment enviroment = ServerInviroment();
  // static String address = '127.0.0.1';
  // static String address = '10.0.2.2';
  // static String address = '192.168.0.21';

  static Future<void> run() async {
    getIt.registerFactory<WebsocketProvider>(
      () => BonfireWebsocket(
        address: Uri.parse(enviroment.wsAddress),
      ),
    );
    getIt.registerLazySingleton(
      () => GameEventManager(
        websocket: inject(),
      ),
    );

    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(
        eventManager: inject(),
      ),
    );
  }
}

T inject<T extends Object>() => getIt.get<T>();
