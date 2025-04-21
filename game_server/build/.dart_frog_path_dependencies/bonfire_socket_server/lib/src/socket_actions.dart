import 'package:bonfire_socket_server/src/socket_client.dart';

/// A mixin that defines the actions that can be performed with a Bonfire socket.
///
/// This mixin provides methods for sending messages, managing rooms, and handling
/// client connections in a Bonfire socket server.
mixin BonfireSocketActions {
  /// Sends a broadcast message to all connected clients.
  ///
  /// - Parameters:
  ///   - event: The event name to broadcast.
  ///   - message: The message to send.
  void sendBroadcast<T>(String event, T message);

  /// Sends a broadcast message to all connected clients except the specified client.
  ///
  /// - Parameters:
  ///   - client: The client to exclude from the broadcast.
  ///   - event: The event name to broadcast.
  ///   - message: The message to send.
  void sendBroadcastFrom<T>(BSocketClient client, String event, T message);

  /// Sends a message to a specific client.
  ///
  /// - Parameters:
  ///   - client: The client to send the message to.
  ///   - event: The event name.
  ///   - message: The message to send.
  void sendTo<T>(BSocketClient client, String event, T message);

  /// Creates a new room with the specified ID.
  ///
  /// - Parameters:
  ///   - roomId: The ID of the room to create.
  void createRoom(String roomId);

  /// Closes the room with the specified ID.
  ///
  /// - Parameters:
  ///   - roomId: The ID of the room to close.
  void closeRoom(String roomId);

  /// Adds a client to the specified room.
  ///
  /// - Parameters:
  ///   - roomId: The ID of the room to enter.
  ///   - client: The client to add to the room.
  void enterRoom(String roomId, BSocketClient client);

  /// Removes a client from the specified room.
  ///
  /// - Parameters:
  ///   - roomId: The ID of the room to leave.
  ///   - client: The client to remove from the room.
  void leaveRoom(String roomId, BSocketClient client);

  /// Sends a message to all clients in the specified room.
  ///
  /// - Parameters:
  ///   - roomId: The ID of the room.
  ///   - event: The event name.
  ///   - message: The message to send.
  void sendToRoom<T>(String roomId, String event, T message);

  /// Retrieves the ID of the room that the specified client is in.
  ///
  /// - Parameters:
  ///   - client: The client whose room ID to retrieve.
  ///
  /// - Returns: The ID of the room the client is in, or `null` if the client is not in any room.
  String? getMyRoomId(BSocketClient client);
}
