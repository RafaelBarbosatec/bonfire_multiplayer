import 'dart:async';

import 'package:bonfire_multiplayer/data/auth/auth_api.dart';
import 'package:bonfire_multiplayer/data/auth/auth_session.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApi _api;
  LoginBloc({required AuthApi api})
      : _api = api,
        super(const LoginState()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
  }

  FutureOr<void> _onSignIn(SignInEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final token = await _api.signIn(
        email: event.email,
        password: event.password,
      );
      AuthSession.instance.saveToken(token);
      emit(const LoginState(success: true));
    } on AuthException catch (e) {
      emit(LoginState(error: e.message));
    } catch (_) {
      emit(const LoginState(error: 'Erro de conexão com o servidor'));
    }
  }

  FutureOr<void> _onSignUp(SignUpEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final token = await _api.signUp(
        email: event.email,
        password: event.password,
      );
      AuthSession.instance.saveToken(token);
      emit(const LoginState(success: true));
    } on AuthException catch (e) {
      emit(LoginState(error: e.message));
    } catch (_) {
      emit(const LoginState(error: 'Erro de conexão com o servidor'));
    }
  }
}
