/// A class representing an event in the Bonfire multiplayer game.
///
/// This class is used to define and manage events that occur within the game.
/// Events can be anything from player actions to game state changes.
///
/// Example usage:
///
/// ```dart
/// BEvent event = BEvent();
/// // Use the event object to handle game events
/// ```
///
/// This class is part of the `bonfire_socket_shared` package.
class BEvent {
  /// Creates a new BEvent instance.
  ///
  /// The [event] parameter specifies the type of event.
  /// The [data] parameter contains the data associated with the event.
  BEvent({required this.event, required this.data});

  /// Creates a new BEvent instance from a map.
  ///
  /// The [map] parameter contains the data to create the BEvent instance.
  /// The map should have keys 'e' for the event type and 'd' for the event data.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// Map<String, dynamic> eventData = {'e': 'player_move', 'd': {'x': 10, 'y': 20}};
  /// BEvent event = BEvent.fromMap(eventData);
  /// ```
  ///
  /// Returns a BEvent instance created from the map.
  factory BEvent.fromMap(Map<String, dynamic> map) {
    return BEvent(
      event: map['e'].toString(),
      data: map['d'],
    );
  }

  /// The type of event.
  ///
  /// This property holds the type of event that occurred. It is a string
  /// that describes the event, such as 'player_move' or 'game_start'.
  final String event;

  /// The data associated with the event.
  ///
  /// This property holds the data related to the event. It can be of any type,
  /// depending on the event. For example, it could be a map containing player
  /// coordinates for a 'player_move' event.
  final dynamic data;

  /// Converts the BEvent instance to a map.
  ///
  /// This method is used to serialize the BEvent object into a map
  /// that can be easily converted to JSON or other formats.
  ///
  /// Returns a map representation of the BEvent instance.
  Map<String, dynamic> toMap() {
    return {
      'e': event,
      'd': data,
    };
  }
}
