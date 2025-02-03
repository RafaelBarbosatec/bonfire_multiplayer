import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  final handler = webSocketHandler((channel, protocol) {
    print(protocol);

    channel.stream.listen((message) {
      // Handle incoming client messages.
      print(message);
      channel.sink.add('echo: $message');
    });
  });
  return handler(context);
}

class BonfireSocket {
  Handler handler() {
    return webSocketHandler((channel, protocol) {
      channel.stream.listen((message) {
        // Handle incoming client messages.
        print(message);
        channel.sink.add('echo: $message');
      });
    });
  }
}

class BSocketClient {
  final String id;
  final WebSocketChannel channel;

  BSocketClient(this.id, this.channel);
}
