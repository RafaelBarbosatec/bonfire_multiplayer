import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../src/api/data/model/user.dart';

Response onRequest(RequestContext context) {
  // ignore: strict_raw_type
  final user = context.read<User>();

  return Response(body: jsonEncode(user.toMap()));
}
