import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../../infrastructure/controller/rest_controller.dart';
import '../datasource/datasource.dart';
import '../model/user.dart';

class AuthRepository {
  AuthRepository({required this.datasource});
  Uuid uuid = const Uuid();

  final Datasource datasource;

  Future<Result<String, String>> signIn(String login, String password) async {
    final userMap = await datasource.get(
      document: User.document,
      test: (element) {
        return element['login'] == login && element['password'] == password;
      },
    );
    if (userMap == null) {
      return const Error('Login or password is incorrect');
    }
    final user = User.fromMap(userMap);
    return Success(_generateToken(user));
  }

  Future<Result<String, String>> signUp(String login, String password) async {
    final userMap = await datasource.get(
      document: User.document,
      test: (element) {
        return element['login'] == login;
      },
    );
    if (userMap != null) {
      return const Error('User already exists');
    }
    final user = User(
      id: uuid.v4(),
      login: login,
      password: password,
    );
    await datasource.insert(
      document: User.document,
      data: user.toMap(),
    );
    return Success(_generateToken(user));
  }

  String _generateToken(User user) {
    final jwt = JWT(
      {
        'user_id': user.id,
      },
    );

    return jwt.sign(SecretKey('secret passphrase'));
  }
}
