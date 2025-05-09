import 'datasource.dart';

final Map<String, List<Map<String, dynamic>>> _data = {};

class MemoryDatasource extends Datasource {
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
  Future<bool> update({
    required String document,
    required Map<String, dynamic> data,
    required bool Function(Map<String, dynamic> element) test,
  }) async {
    final database = _data[document];
    if (database == null) {
      return false;
    }
    final index = database.indexWhere(test);
    if (index == -1) {
      return false;
    }
    database[index] = data;
    return true;
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
  Future<Map<String, dynamic>?> getFirst({
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
  Future<List<Map<String, dynamic>>> get({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  }) {
    final data = _data[document];
    if (data == null) {
      return Future.value([]);
    }
    try {
      return Future.value(data.where(test).toList());
    } catch (e) {
      return Future.value([]);
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
