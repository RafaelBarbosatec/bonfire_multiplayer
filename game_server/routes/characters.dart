import '../../src/api/controllers/character_controller.dart';
import '../../src/infrastructure/controller/rest_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  return context.read<CharacterController>().onRequest(context);
}
