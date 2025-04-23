import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

import '../src/api/data/model/user_model.dart';
import '../src/api/usecases/authenticator.dart';

final pathsNotAuthenticated = [
  '/auth/sign_in',
  '/auth/sign_up',
  '/',
];

Handler middleware(Handler handler) {
  return handler.use(
    bearerAuthentication<UserModel>(
      authenticator: (context, token) async {
        final authenticator = context.read<Authenticator>();
        return authenticator.verifyToken(token);
      },
      applies: (context) async {
        final path = context.request.uri.path;
        return !pathsNotAuthenticated.contains(path);
      },
    ),
  );
}
