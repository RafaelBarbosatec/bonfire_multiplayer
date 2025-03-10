abstract class Datasource {
  Future<void> saveDocument({
    required String document,
    required List<Map<String, dynamic>> data,
  });
  Future<List<Map<String, dynamic>>> loadDocument({
    required String document,
  });
  Future<void> deleteDocument({
    required String document,
  });
  Future<void> insert({
    required String document,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>?> get({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  });
  Future<void> delete({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  });
}
