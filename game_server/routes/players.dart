import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../src/api/data/model/user_model.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final user = context.read<UserModel>();

  return Response(body: jsonEncode(user.toMap()));
}
