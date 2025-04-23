import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../data/model/user_model.dart';

class GenerateJwtUsecase {
  GenerateJwtUsecase({required this.secretKey});

  final String secretKey;

  String call(UserModel user) {
    final jwt = JWT(
      {
        'user_id': user.id,
        'login': user.login,
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return jwt.sign(SecretKey(secretKey));
  }
}
