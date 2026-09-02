import '../../src/api/controllers/sign_up_controller.dart';
import '../../src/infrastructure/controller/rest_controller.dart';

Future<Response> onRequest(RequestContext context) async {
  return context.read<SignUpController>().onRequest(context);
}
