import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

extension RequestContextExt on RequestContext {
  Future<Map<String, dynamic>> bodyAsMap() async {
    final raw = await request.body();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
