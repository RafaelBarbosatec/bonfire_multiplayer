// ignore_for_file: public_member_api_docs, sort_constructors_first

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.password,
  });
  final String id;
  final String email;
  final String password;
  static const document = 'users';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }
}
