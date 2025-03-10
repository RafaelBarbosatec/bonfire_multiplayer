import 'datasource.dart';

class MemoryDatasource extends Datasource {
  final Map<String, List<Map<String, dynamic>>> _data = {};

  @override
  Future<void> deleteDocument({required String document}) {
    _data.remove(document);
    return Future.value();
  }

  @override
  Future<void> insert({
    required String document,
    required Map<String, dynamic> data,
  }) {
    if (_data.containsKey(document)) {
      _data[document]!.add(data);
    } else {
      _data[document] = [data];
    }
    return Future.value();
  }

  @override
  Future<List<Map<String, dynamic>>> loadDocument({required String document}) {
    return Future.value(_data[document] ?? []);
  }

  @override
  Future<void> saveDocument({
    required String document,
    required List<Map<String, dynamic>> data,
  }) {
    _data[document] = data;
    return Future.value();
  }

  @override
  Future<Map<String, dynamic>?> get({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  }) {
    final data = _data[document];
    if (data == null) {
      return Future.value();
    }
    try {
      return Future.value(data.firstWhere(test));
    } catch (e) {
      return Future.value();
    }
  }

  @override
  Future<void> delete({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  }) {
    final data = _data[document];
    if (data == null) {
      return Future.value();
    }
    data.removeWhere(test);
    return Future.value();
  }
}
