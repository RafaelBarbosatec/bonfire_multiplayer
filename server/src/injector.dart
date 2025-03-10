import 'package:dart_frog/dart_frog.dart';

import 'data/datasource/datasource.dart';
import 'data/datasource/memory_datasource.dart';

abstract class Injector {
  static Handler run(Handler handler) {
    return handler.use(
      provider<Datasource>(
        (context) => MemoryDatasource(),
      ),
    );
  }
}
