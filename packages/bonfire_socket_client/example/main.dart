import 'package:bonfire_socket_client/bonfire_socket_client.dart';

void main() {
  // Connect to the remote WebSocket endpoint.
  final uri = Uri.parse('ws://localhost:8080/ws');
  final socket = BonfireSocket(uri: uri);
  socket.conect(
    onConnected: () {
      print('Connected');
      // Send a message to the server.
      socket.send('oi', 'messagem teste');
    },
    onDisconnected: (reason) {
      print('Disconnected: $reason');
    },
  );

  socket.on('ola', (String message) {
    print('Message received: $message');
  });
}
