part of 'login_bloc.dart';

class LoginState extends Equatable {
  const LoginState({
    this.loading = false,
    this.success = false,
    this.error,
  });

  final bool loading;
  final bool success;
  final String? error;

  @override
  List<Object?> get props => [loading, success, error];

  LoginState copyWith({
    bool? loading,
    bool? success,
    String? error,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }
}
