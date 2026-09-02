import 'dart:io';

class ApiResponse {
  ApiResponse({required this.code, this.body});

  factory ApiResponse.success(dynamic body) {
    return ApiResponse(
      code: HttpStatus.ok,
      body: body,
    );
  }

  factory ApiResponse.created(dynamic body) {
    return ApiResponse(
      code: HttpStatus.created,
      body: body,
    );
  }

  factory ApiResponse.badRequest(dynamic body) {
    return ApiResponse(
      code: HttpStatus.badRequest,
      body: body,
    );
  }

  factory ApiResponse.unauthorized() {
    return ApiResponse(
      code: HttpStatus.unauthorized,
    );
  }

  factory ApiResponse.noContent() {
    return ApiResponse(
      code: HttpStatus.noContent,
    );
  }

  final int code;
  final dynamic body;
}
