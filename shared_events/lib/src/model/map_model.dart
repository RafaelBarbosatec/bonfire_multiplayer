// ignore_for_file: public_member_api_docs, sort_constructors_first

class MapModel {
  final String name;
  final String path;

  MapModel({required this.name, required this.path});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
    };
  }

  factory MapModel.fromMap(Map<String, dynamic> map) {
    return MapModel(
      name: map['name'] as String,
      path: map['path'] as String,
    );
  }
}
