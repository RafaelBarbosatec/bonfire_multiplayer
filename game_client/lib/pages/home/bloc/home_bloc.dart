import 'dart:async';

import 'package:bonfire_multiplayer/data/game_event_manager.dart';
import 'package:bonfire_multiplayer/data/repositories/ntp_repository.dart';
import 'package:bonfire_multiplayer/util/player_skin.dart';
import 'package:bonfire_multiplayer/util/time_sync.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_events/shared_events.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GameEventManager _eventManager;
  final TimeSync _timeSync;
  final NtpRepository _ntpRepository;
  HomeBloc({
    required GameEventManager eventManager,
    required TimeSync timeSync,
    required NtpRepository ntpRepository,
  })  : _eventManager = eventManager,
        _timeSync = timeSync,
        _ntpRepository = ntpRepository,
        super(const HomeState()) {
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
    try {
      await _syncServerTime();
      await _eventManager.connect(
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
      );
    } catch (e) {
      print(e);
      emit(state.copyWith(error: true));
    }
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

  Future<void> _syncServerTime() async {
    await _timeSync.synchronize(_ntpRepository.getNtpTime);
    print(_timeSync.roundTripTime);
    final now = DateTime.now();
    print('now: $now');
    print(_timeSync.serverTime);
    
  }
}
