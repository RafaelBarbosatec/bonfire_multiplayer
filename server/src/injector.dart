import 'package:dart_frog/dart_frog.dart';

import 'controllers/sign_in_controller.dart';
import 'controllers/sign_up_controller.dart';
import 'data/datasource/datasource.dart';
import 'data/datasource/memory_datasource.dart';
import 'data/repositories/auth_repository.dart';

abstract class Injector {
  static Handler run(Handler handler) {
    return handler
        .use(
          provider(
            (context) => SignInController(
              repository: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => SignUpController(
              repository: context.read(),
            ),
          ),
        )
        .use(
          provider(
            (context) => AuthRepository(
              datasource: context.read(),
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
