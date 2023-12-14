class RegisterEvent {
  RegisterEvent({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }

  factory RegisterEvent.fromMap(Map<String, dynamic> map) {
    return RegisterEvent(
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}

class RegisterResponseEvent {
  RegisterResponseEvent({required this.success, this.errorMessage});

  final bool success;
  final String? errorMessage;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'errorMessage': errorMessage,
    };
  }

  factory RegisterResponseEvent.fromMap(Map<String, dynamic> map) {
    return RegisterResponseEvent(
      success: map['success'] as bool,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
