import 'dart:async';

import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GameEventManager _eventManager;
  HomeBloc(this._eventManager) : super(const HomeState()) {
    on<ConnectEvent>(_onConnectEvent);
    on<ConnectedEvent>(_onConnectedEvent);
    on<DisconnectedEvent>(_onDisconnectedEvent);
    on<EnterGameEvent>(_onEnterGameEvent);
    on<SelectSkinEvent>(_onSelectSkin);
    on<JoinGameEvent>(_onJoinGameEvent);
    on<DisposeEvent>(_onDisposeEvent);
  }

  FutureOr<void> _onConnectEvent(
    ConnectEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _eventManager.connect(
      onConnect: _onConnect,
      onDisconnect: _onDisconnect,
    );
  }

  void _onDisconnect() {
    add(DisconnectedEvent());
  }

  void _onConnect() {
    add(ConnectedEvent());
  }

  FutureOr<void> _onConnectedEvent(
    ConnectedEvent event,
    Emitter<HomeState> emit,
  ) {
    _eventManager.onJoinMapEvent((event) {
      add(EnterGameEvent(ackEvent: event));
    });
    emit(state.copyWith(connected: true));
  }

  FutureOr<void> _onDisconnectedEvent(
    DisconnectedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(connected: false));
  }

  FutureOr<void> _onEnterGameEvent(
    EnterGameEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(ackEvent: event.ackEvent));
  }

  FutureOr<void> _onSelectSkin(SelectSkinEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(skinSelected: event.skin));
  }

  FutureOr<void> _onJoinGameEvent(
    JoinGameEvent event,
    Emitter<HomeState> emit,
  ) {
    _eventManager.send<JoinEvent>(
      EventType.JOIN.name,
      JoinEvent(
        name: event.name,
        skin: state.skinSelected.name,
      ),
    );
  }

  FutureOr<void> _onDisposeEvent(DisposeEvent event, Emitter<HomeState> emit) {
    emit(const HomeState());
  }
}
