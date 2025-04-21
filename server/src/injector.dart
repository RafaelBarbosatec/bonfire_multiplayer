import 'package:dart_frog/dart_frog.dart';

import 'api/controllers/sign_in_controller.dart';
import 'api/controllers/sign_up_controller.dart';
import 'api/data/datasource/datasource.dart';
import 'api/data/datasource/memory_datasource.dart';
import 'api/data/repositories/user_repository.dart';
import 'api/usecases/authenticator.dart';
import 'api/usecases/generate_jwt_usecase.dart';
import 'config.dart';

abstract class Injector {
  static Handler run(Handler handler) {
    return handler
        .use(
          provider(
            (context) => SignInController(
              repository: context.read(),
              generateJwtUsecase: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => SignUpController(
              repository: context.read(),
              generateJwtUsecase: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => Authenticator(
              context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => UserRepository(
              datasource: context.read(),
            ),
          ),
        )
        .use(
          provider<GenerateJwtUsecase>(
            (context) => GenerateJwtUsecase(
              secretKey: Config.secretJWT,
            ),
          ),
        )
        .use(
          provider<Datasource>(
            (context) => MemoryDatasource(),
          ),
        );
  }
}
