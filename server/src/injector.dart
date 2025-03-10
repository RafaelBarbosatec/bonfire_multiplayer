import 'package:dart_frog/dart_frog.dart';

import 'controllers/sign_in_controller.dart';
import 'controllers/sign_up_controller.dart';
import 'data/datasource/datasource.dart';
import 'data/datasource/memory_datasource.dart';

abstract class Injector {
  static Handler run(Handler handler) {
    return handler
        .use(
          provider<Datasource>(
            (context) => MemoryDatasource(),
          ),
        )
        .use(
          provider(
            (context) => SignInController(),
          ),
        )
        .use(
          provider(
            (context) => SignUpController(),
          ),
        );
  }
}
