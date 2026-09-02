import 'package:bonfire_multiplayer/data/auth/auth_api.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/websocket/bonfire_websocket.dart';
import 'package:bonfire_multiplayer/data/websocket/websocket_provider.dart';
import 'package:bonfire_multiplayer/pages/characters/bloc/character_select_bloc.dart';
import 'package:bonfire_multiplayer/pages/home/bloc/home_bloc.dart';
import 'package:bonfire_multiplayer/pages/login/bloc/login_bloc.dart';
import 'package:bonfire_multiplayer/util/enviroment.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class BootstrapInjector {
  // static BaseInviroment enviroment = LocalInviroment();
  static BaseInviroment enviroment = LocalInviroment();

  static Future<void> run() async {
    getIt.registerLazySingleton<WebsocketProvider>(
      () => BonfireWebsocket(
        address: Uri.parse(enviroment.wsAddress),
      ),
    );
    getIt.registerLazySingleton(
      () => GameEventManager(
        websocket: inject(),
      ),
    );
    getIt.registerLazySingleton<AuthApi>(
      () => AuthApi(),
    );

    getIt.registerFactory<LoginBloc>(
      () => LoginBloc(
        api: inject(),
      ),
    );

    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(
        eventManager: inject(),
      ),
    );

    getIt.registerFactory<CharacterSelectBloc>(
      () => CharacterSelectBloc(
        api: inject(),
        eventManager: inject(),
      ),
    );
  }
}

T inject<T extends Object>() => getIt.get<T>();
