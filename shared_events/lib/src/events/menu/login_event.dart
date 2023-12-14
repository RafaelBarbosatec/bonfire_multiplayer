class LoginEvent {
  LoginEvent({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  factory LoginEvent.fromMap(Map<String, dynamic> map) {
    return LoginEvent(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}

class LoginResponseEvent {
  LoginResponseEvent({required this.success, this.errorMessage});

  final bool success;
  final String? errorMessage;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  factory LoginResponseEvent.fromMap(Map<String, dynamic> map) {
    return LoginResponseEvent(
      success: map['success'] as bool,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
