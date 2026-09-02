import 'package:bonfire_socket_shared/bonfire_socket_shared.dart';

/// A mixin that provides functionality to register and use type adapters
/// for converting objects to and from maps.
mixin BonfireTypeAdapterProvider {
  final Map<String, BTypeAdapter<dynamic>> _typeAdapters = {};

  /// Registers a [BTypeAdapter] for a specific type [T].
  ///
  /// The [typeAdapter] parameter is the adapter to be registered.
  void registerType<T>(BTypeAdapter<T> typeAdapter) {
    _typeAdapters[T.toString()] = typeAdapter;
  }

  /// Converts an object of type [T] to a map using the registered type adapter.
  ///
  /// The [data] parameter is the object to be converted.
  /// Returns a map representation of the object, or null if no adapter is registered.
  Map<String, dynamic>? toMap<T>(T data) {
    final typeString = T.toString();
    if (_typeAdapters.containsKey(typeString)) {
      final adapter = _typeAdapters[typeString]! as BTypeAdapter<T>;
      return adapter.toMap(data);
    }
    return null;
  }

  /// Converts a map to an object of type [T] using the registered type adapter.
  ///
  /// The [data] parameter is the map to be converted.
  /// Returns an object of type [T], or the original data if no adapter is registered.
  T toType<T>(dynamic data) {
    final typeString = T.toString();
    if (_typeAdapters.containsKey(typeString)) {
      final adapter = _typeAdapters[typeString]! as BTypeAdapter<T>;
      return adapter.fromMap((data as Map).cast());
    }
    return data as T;
  }
}
