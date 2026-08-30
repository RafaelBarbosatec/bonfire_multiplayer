import 'dart:convert';

import 'package:bonfire_multiplayer/bootstrap_injector.dart';
import 'package:bonfire_multiplayer/data/models/character_summary.dart';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// REST client for the auth + characters endpoints.
class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) =>
      Uri.parse('${BootstrapInjector.enviroment.restAddress}$path');

  Map<String, String> _jsonHeaders([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _message(http.Response response, Map<String, dynamic> body) {
    return body['message']?.toString() ??
        'Erro inesperado (${response.statusCode})';
  }

  /// POST /auth/sign_in → returns the JWT.
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/sign_in'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw AuthException(_message(response, body));
    }
    return body['jwt'] as String;
  }

  /// POST /auth/sign_up → creates the account and returns the JWT.
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/sign_up'),
      headers: _jsonHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = _decode(response);
    if (response.statusCode != 200) {
      throw AuthException(_message(response, body));
    }
    return body['jwt'] as String;
  }

  /// GET /characters → the logged user's characters.
  Future<List<CharacterSummary>> getCharacters(String token) async {
    final response = await _client.get(
      _uri('/characters'),
      headers: _jsonHeaders(token),
    );
    if (response.statusCode != 200) {
      throw AuthException(_message(response, _decode(response)));
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((e) => CharacterSummary.fromMap((e as Map).cast()))
        .toList();
  }

  /// POST /characters → creates a character for the logged user.
  Future<CharacterSummary> createCharacter(
    String token, {
    required String nickName,
    required String skin,
  }) async {
    final response = await _client.post(
      _uri('/characters'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'nickName': nickName, 'skin': skin}),
    );
    final body = _decode(response);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(_message(response, body));
    }
    return CharacterSummary.fromMap(body);
  }
}
