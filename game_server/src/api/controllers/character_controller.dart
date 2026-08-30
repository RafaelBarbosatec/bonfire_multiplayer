import 'package:uuid/uuid.dart';

import '../../infrastructure/controller/failure.dart';
import '../../infrastructure/controller/response.dart';
import '../../infrastructure/controller/rest_controller.dart';
import '../../infrastructure/extenssions/request_context_ext.dart';
import '../data/model/character_model.dart';
import '../data/model/user_model.dart';
import '../data/repositories/character_repository.dart';

/// REST controller for the authenticated user's characters.
///
/// The `UserModel` is injected by the bearer auth middleware, so every
/// operation is scoped to the logged user.
class CharacterController extends RestController {
  CharacterController({required this.repository});

  final CharacterRepository repository;
  final Uuid uuid = const Uuid();

  /// Default spawn used when a character is created (florest map).
  static const double _defaultSpawnX = 64;
  static const double _defaultSpawnY = 176;
  static const String _defaultMapId = 'florestId';

  @override
  Future<Result<ApiResponse, Failure>>? get(RequestContext context) async {
    final user = context.read<UserModel>();
    final result = await repository.get(user.id);
    return result.when(
      (characters) => Success(
        ApiResponse.success(
          characters.map((e) => e.toMap()).toList(),
        ),
      ),
      (error) => Error(
        Failure.badRequest(message: error.toString()),
      ),
    );
  }

  @override
  Future<Result<ApiResponse, Failure>>? post(RequestContext context) async {
    final user = context.read<UserModel>();
    final body = await context.bodyAsMap();
    final nickName = body['nickName'] as String?;
    final skin = body['skin'] as String?;

    if (nickName == null || nickName.trim().isEmpty) {
      return Error(Failure.badRequest(message: 'nickName is required'));
    }
    if (skin == null || skin.isEmpty) {
      return Error(Failure.badRequest(message: 'skin is required'));
    }

    final character = CharacterModel(
      id: uuid.v4(),
      nickName: nickName.trim(),
      skin: skin,
      userId: user.id,
      position: CharacterPosition(
        x: _defaultSpawnX,
        y: _defaultSpawnY,
      ),
      mapId: _defaultMapId,
    );
    final result = await repository.create(character);
    return result.when(
      (c) => Success(ApiResponse.created(c.toMap())),
      (error) => Error(
        Failure.badRequest(message: error.toString()),
      ),
    );
  }
}
