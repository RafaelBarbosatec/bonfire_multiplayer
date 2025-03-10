import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:multiple_result/multiple_result.dart';

import 'failure.dart';
import 'response.dart';

extension EitherApiResponseExt on Result<ApiResponse, Failure> {
  Response toResponse() {
    return when(
      (success) => Response.json(
        body: success.body,
        statusCode: success.code,
      ),
      (failure) => Response.json(
        body: failure.toMap(),
        statusCode: failure.statusCode ?? HttpStatus.badRequest,
      ),
    );
  }
}
