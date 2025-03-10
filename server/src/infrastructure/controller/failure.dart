// ignore_for_file: public_member_api_docs, sort_constructors_first

class Failure {
  Failure({
    required this.message,
    required this.code,
    this.statusCode,
  });

  final String message;
  final String code;
  final int? statusCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'code': code,
    };
  }
}

class InternalServerFailure extends Failure {
  InternalServerFailure({
    required super.message,
    super.code = '',
  });
}
