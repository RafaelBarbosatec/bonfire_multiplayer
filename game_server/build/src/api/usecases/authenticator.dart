import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../data/model/user_model.dart';
import '../data/repositories/user_repository.dart';

class Authenticator {
  Authenticator(this.repository);
  final UserRepository repository;

  Future<UserModel?> verifyToken(String token) async {
    final data = JWT.tryDecode(token);
    if (data != null) {
      final user = await repository.getById(
        (data.payload as Map?)?['user_id']?.toString() ?? '',
      );
      return user.when(
        (user) => user,
        (error) => null,
      );
    }
    return null;
  }
}
