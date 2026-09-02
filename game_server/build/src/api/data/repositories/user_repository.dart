import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/controller/rest_controller.dart';
import '../datasource/datasource.dart';
import '../exceptions/create_user_exception.dart';
import '../exceptions/get_user_exception.dart';
import '../model/user_model.dart';

class UserRepository {
  UserRepository({required this.datasource});
  Uuid uuid = const Uuid();

  final Datasource datasource;

  /// Hashes a password with a per-user salt (the user id).
  ///
  /// Not bcrypt/argon2 (that needs native deps) — good enough for the
  /// current stage; swap for a KDF when moving to a real database.
  String hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt|$password')).toString();
  }

  Future<Result<UserModel, GetUserException>> getUserByEmail(
    String email,
    String password,
  ) async {
    final userMap = await datasource.getFirst(
      document: UserModel.document,
      test: (element) {
        return element['email'] == email;
      },
    );
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    final user = UserModel.fromMap(userMap);
    // Constant-ish comparison: hashed compare to avoid leaking which part failed.
    if (user.password != hashPassword(password, user.id)) {
      return Error(NotFoundUserException());
    }
    return Success(user);
  }

  Future<Result<UserModel, GetUserException>> getById(
    String id,
  ) async {
    final userMap = await datasource.getFirst(
      document: UserModel.document,
      test: (element) {
        return element['id'] == id;
      },
    );
    if (userMap == null) {
      return Error(NotFoundUserException());
    }
    return Success(UserModel.fromMap(userMap));
  }

  Future<Result<UserModel, CreateUserException>> createUser(
    String email,
    String password,
  ) async {
    final userMap = await datasource.getFirst(
      document: UserModel.document,
      test: (element) {
        return element['email'] == email;
      },
    );
    if (userMap != null) {
      return Error(UserAlreadyExistException());
    }
    final id = uuid.v4();
    final user = UserModel(
      id: id,
      email: email,
      password: hashPassword(password, id),
    );
    await datasource.insert(
      document: UserModel.document,
      data: user.toMap(),
    );
    return Success(user);
  }
}
