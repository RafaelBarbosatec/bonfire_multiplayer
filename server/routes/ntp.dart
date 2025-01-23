import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
    body: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
  );
}
