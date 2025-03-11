import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:multiple_result/multiple_result.dart';

import 'extension.dart';
import 'failure.dart';
import 'response.dart';

export 'package:dart_frog/dart_frog.dart';
export 'package:multiple_result/multiple_result.dart';

abstract class RestController {
  Future<Result<ApiResponse, Failure>>? post(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? get(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? put(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? delete(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? head(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? patch(RequestContext context) => null;
  Future<Result<ApiResponse, Failure>>? options(RequestContext context) => null;

  Future<Response> onRequest(RequestContext context) async {
    Future<Result<ApiResponse, Failure>>? resp;
    switch (context.request.method) {
      case HttpMethod.post:
        resp = post(context);
      case HttpMethod.delete:
        resp = delete(context);
      case HttpMethod.get:
        resp = get(context);
      case HttpMethod.put:
        resp = put(context);
      case HttpMethod.head:
        resp = head(context);
      case HttpMethod.options:
        resp = options(context);
      case HttpMethod.patch:
        resp = patch(context);
    }
    try {
      if (resp != null) {
        return (await resp).toResponse();
      }
    } catch (e, stacktrace) {
      final error = {
        'status': 'error',
        'message': e.toString(),
        'stacktrace': stacktrace.toString(),
      };
      return Future.value(
        Response.json(
          statusCode: HttpStatus.internalServerError,
          body: error,
        ),
      );
    }
    return _methodNotAllowed;
  }

  Future<Response> get _methodNotAllowed => Future.value(
        Response(statusCode: HttpStatus.methodNotAllowed),
      );
}
