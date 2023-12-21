class GameClient<T> {
  GameClient({required this.id, required this.socketClient});

  final String id;
  final T socketClient;
}
