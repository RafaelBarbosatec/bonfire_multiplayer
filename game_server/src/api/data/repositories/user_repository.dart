import 'package:uuid/uuid.dart';

import '../../../infrastructure/controller/rest_controller.dart';
import '../datasource/datasource.dart';
import '../exceptions/create_user_exception.dart';
import '../exceptions/get_user_exception.dart';
import '../model/user.dart';

class UserRepository {
  UserRepository({required this.datasource});
  Uuid uuid = const Uuid();

  final Datasource datasource;

  Future<Result<User, GetUserException>> getUserByLogin(
    String login,
    String password,
  ) async {
    final userMap = await datasource.get(
      document: User.document,
      test: (element) {
        return element['login'] == login && element['password'] == password;
      },
    );
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(User.fromMap(userMap));
  }

  Future<Result<User, GetUserException>> getById(
    String id,
  ) async {
    final userMap = await datasource.get(
      document: User.document,
      test: (element) {
        return element['id'] == id;
      },
    );
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(User.fromMap(userMap));
  }

  Future<Result<User, CreateUserException>> createuser(
    String login,
    String password,
  ) async {
    final userMap = await datasource.get(
      document: User.document,
      test: (element) {
        return element['login'] == login;
      },
    );
    if (userMap != null) {
      return Error(UserAlreadyExistException());
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
    return Success(user);
  }
}
