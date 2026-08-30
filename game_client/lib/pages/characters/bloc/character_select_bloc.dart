import 'dart:async';

import 'package:bonfire_multiplayer/data/auth/auth_api.dart';
import 'package:bonfire_multiplayer/data/auth/auth_session.dart';
import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/models/character_summary.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'character_select_event.dart';
part 'character_select_state.dart';

class CharacterSelectBloc
    extends Bloc<CharacterSelectEvent, CharacterSelectState> {
  final AuthApi _api;
  final GameEventManager _eventManager;

  /// Character/token being joined — used when the websocket connects.
  CharacterSummary? _pendingCharacter;
  String? _pendingToken;

  CharacterSelectBloc({
    required AuthApi api,
    required GameEventManager eventManager,
  })  : _api = api,
        _eventManager = eventManager,
        super(const CharacterSelectState()) {
    on<LoadCharactersEvent>(_onLoadCharacters);
    on<CreateCharacterEvent>(_onCreateCharacter);
    on<SelectCharacterEvent>(_onSelectCharacter);
    on<EnterGameEvent>(_onEnterGame);
    on<JoinErrorEvent>(_onJoinError);
    on<LogoutEvent>(_onLogout);
  }

  FutureOr<void> _onLoadCharacters(
    LoadCharactersEvent event,
    Emitter<CharacterSelectState> emit,
  ) async {
    final token = AuthSession.instance.token;
    if (token == null) {
      emit(state.copyWith(error: 'Sessão expirada, faça login novamente'));
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      final characters = await _api.getCharacters(token);
      emit(state.copyWith(loading: false, characters: characters));
    } on AuthException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Erro ao carregar personagens'));
    }
  }

  FutureOr<void> _onCreateCharacter(
    CreateCharacterEvent event,
    Emitter<CharacterSelectState> emit,
  ) async {
    final token = AuthSession.instance.token;
    if (token == null) {
      emit(state.copyWith(error: 'Sessão expirada, faça login novamente'));
      return;
    }
    emit(state.copyWith(creating: true, error: null));
    try {
      await _api.createCharacter(
        token,
        nickName: event.nickName,
        skin: event.skin.name,
      );
      emit(state.copyWith(creating: false));
      add(LoadCharactersEvent());
    } on AuthException catch (e) {
      emit(state.copyWith(creating: false, error: e.message));
    } catch (_) {
      emit(state.copyWith(creating: false, error: 'Erro ao criar personagem'));
    }
  }

  FutureOr<void> _onSelectCharacter(
    SelectCharacterEvent event,
    Emitter<CharacterSelectState> emit,
  ) async {
    final token = AuthSession.instance.token;
    if (token == null) return;
    emit(state.copyWith(joining: true, error: null));
    _pendingCharacter = event.character;
    _pendingToken = token;
    try {
      await _eventManager.connect(
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
      );
    } catch (_) {
      emit(state.copyWith(
        joining: false,
        error: 'Erro ao conectar no servidor',
      ));
      return;
    }
    // Safety net: if the server never ACKs the join (invalid/expired token,
    // character not found), release the loading state after 10s.
    Future.delayed(const Duration(seconds: 10), () {
      if (!isClosed && state.joining) {
        add(JoinErrorEvent(message: 'O servidor não respondeu. Tente novamente.'));
      }
    });
  }

  void _onConnect() {
    final character = _pendingCharacter;
    final token = _pendingToken;
    if (character == null || token == null) return;
    _eventManager.onJoinMapEvent(_onJoinMapEvent);
    _eventManager.send<JoinEvent>(
      EventType.JOIN.name,
      JoinEvent(
        name: character.nickName,
        skin: character.skin,
        token: token,
        characterId: character.id,
      ),
    );
  }

  void _onJoinMapEvent(JoinMapEvent event) {
    add(EnterGameEvent(ackEvent: event));
  }

  void _onDisconnect() {
    add(JoinErrorEvent(message: 'Conexão com o servidor perdida'));
  }

  FutureOr<void> _onEnterGame(
    EnterGameEvent event,
    Emitter<CharacterSelectState> emit,
  ) {
    _pendingCharacter = null;
    _pendingToken = null;
    emit(state.copyWith(joining: false, ackEvent: event.ackEvent));
  }

  FutureOr<void> _onJoinError(
    JoinErrorEvent event,
    Emitter<CharacterSelectState> emit,
  ) {
    emit(state.copyWith(joining: false, error: event.message));
  }

  FutureOr<void> _onLogout(
    LogoutEvent event,
    Emitter<CharacterSelectState> emit,
  ) {
    AuthSession.instance.clear();
    _pendingCharacter = null;
    _pendingToken = null;
    emit(const CharacterSelectState());
  }
}
