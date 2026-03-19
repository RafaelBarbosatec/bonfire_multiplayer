// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

class Failure {
  Failure({
    required this.message,
    required this.code,
    required this.statusCode,
  });

  final String message;
  final String code;
  final int statusCode;

  factory Failure.badRequest({
    required String message,
    String code = '',
  }) {
    return Failure(
      message: message,
      code: code,
      statusCode: HttpStatus.badRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'code': code,
    };
  }
}
