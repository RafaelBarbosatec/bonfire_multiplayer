import 'package:multiple_result/multiple_result.dart';
import 'package:uuid/uuid.dart';

import '../datasource/datasource.dart';
import '../exceptions/create_character_exception.dart';
import '../exceptions/get_character_exception.dart';
import '../model/character_model.dart';

class CharacterRepository {
  CharacterRepository({
    required this.datasource,
  });
  Uuid uuid = const Uuid();

  final Datasource datasource;

  Future<Result<List<CharacterModel>, GetCharacterException>> get(
    String userId,
  ) async {
    final characterMap = await datasource.get(
      document: CharacterModel.document,
      test: (element) {
        return element['userId'] == userId;
      },
    );
    if (characterMap.isEmpty) {
      return const Success([]);
    }
    return Success(
      characterMap
          .map((e) => CharacterModel.fromMap((e as Map).cast()))
          .toList(),
    );
  }

  Future<Result<CharacterModel, GetCharacterException>> getById(
    String characterId,
  ) async {
    final characterMap = await datasource.getFirst(
      document: CharacterModel.document,
      test: (element) {
        return element['id'] == characterId;
      },
    );
    if (characterMap == null) {
      return Error(GetCharacterException());
    }
    return Success(
      CharacterModel.fromMap(characterMap.cast()),
    );
  }

  Future<Result<CharacterModel, CreateCharacterException>> create(
    CharacterModel character,
  ) async {
    await datasource.insert(
      document: CharacterModel.document,
      data: character.toMap(),
    );
    return Success(character);
  }

  Future<Result<CharacterModel, CreateCharacterException>> update(
    CharacterModel character,
  ) async {
    await datasource.update(
      document: CharacterModel.document,
      test: (element) {
        return element['id'] == character.id;
      },
      data: character.toMap(),
    );
    return Success(character);
  }
}
