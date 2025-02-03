/// A generic adapter class for converting objects to and from maps.
///
/// This class is used to serialize and deserialize objects of type `T`
/// to and from `Map<String, dynamic>`. It requires two functions:
/// - `toMap`: Converts an object of type `T` to a map.
/// - `fromMap`: Converts a map to an object of type `T`.
class BTypeAdapter<T> {
  BTypeAdapter({required this.toMap, required this.fromMap});
  final Map<String, dynamic> Function(T type) toMap;
  final T Function(Map<String, dynamic> map) fromMap;
}
