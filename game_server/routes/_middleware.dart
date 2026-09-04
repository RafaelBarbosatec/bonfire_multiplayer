import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

import '../src/api/data/model/user_model.dart';
import '../src/api/usecases/authenticator.dart';

final pathsNotAuthenticated = [
  '/auth/sign_in',
  '/auth/sign_up',
  '/auth/refresh_token',
  '/ws',
  '/',
];

/// Prefixes that never require auth. Map files are public game content —
/// the client fetches them via plain HTTP (WorldMapReader.fromNetwork).
final pathPrefixesNotAuthenticated = [
  '/maps/',
];

const _corsHeaders = <String, String>{
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      'Origin, X-Requested-With, Content-Type, Accept, Authorization',
};

bool _isPublicPath(String path) {
  if (pathsNotAuthenticated.contains(path)) return true;
  for (final prefix in pathPrefixesNotAuthenticated) {
    if (path.startsWith(prefix)) return true;
  }
  return false;
}

Handler middleware(Handler handler) {
  final authHandler = handler.use(
    bearerAuthentication<UserModel>(
      authenticator: (context, token) async {
        final authenticator = context.read<Authenticator>();
        return authenticator.verifyToken(token);
      },
      applies: (context) async {
        final path = context.request.uri.path;
        return !_isPublicPath(path);
      },
    ),
  );

  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(headers: _corsHeaders);
    }

    final response = await authHandler(context);
    return response.copyWith(
      headers: {
        ...response.headers,
        ..._corsHeaders,
      },
    );
  };
}
