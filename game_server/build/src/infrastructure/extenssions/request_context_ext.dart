import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

extension RequestContextExt on RequestContext {
  Future<Map<String, dynamic>> bodyAsMap() async {
    final raw = await request.body();
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
