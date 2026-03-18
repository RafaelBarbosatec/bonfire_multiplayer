// ignore_for_file: public_member_api_docs

class TimeSync {
  Duration _serverDifference = Duration.zero;
  int _roundTripTime = 0;
  final List<int> _rttSamples = [];
  static const int _maxSamples = 5;

  Future<void> synchronize(Future<DateTime> Function() getServerTime) async {
    try {
      final requestTime = DateTime.now();
      final serverTime = await getServerTime();
      final responseTime = DateTime.now();

      final roundTripTime = responseTime.difference(requestTime);
      final rttMicros = roundTripTime.inMicroseconds;
      
      // Store RTT samples for averaging
      _rttSamples.add(rttMicros);
      if (_rttSamples.length > _maxSamples) {
        _rttSamples.removeAt(0);
      }
      
      // Use average RTT for more stable timing
      _roundTripTime = _rttSamples.reduce((a, b) => a + b) ~/ _rttSamples.length;
      
      final adjustedServerTime = serverTime.add(Duration(microseconds: _roundTripTime ~/ 2));

      _serverDifference = adjustedServerTime.difference(responseTime);
      _log('diff: $_serverDifference');
      _log('roundTripTime: ${Duration(microseconds: _roundTripTime)} (avg of ${_rttSamples.length} samples)');
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Converte um timestamp do servidor para tempo local
  DateTime serverTimeToLocal(DateTime serverTime) {
    /// Primeiro ajusta o offset de sincronização
    final synchronizedTime = serverTime.subtract(_serverDifference);

    /// Depois converte para o fuso horário local
    return synchronizedTime;
  }

  /// Converte tempo local para tempo do servidor
  DateTime localTimeToServer(DateTime localTime) {
    final utcTime = localTime;

    /// Depois remove o offset de sincronização
    return utcTime.add(_serverDifference);
  }

  /// Converte um timestamp do servidor para tempo local
  DateTime serverTimestampToLocal(int serverTimestamp) {
    final serverTime = DateTime.fromMicrosecondsSinceEpoch(serverTimestamp);
    return serverTimeToLocal(serverTime);
  }

  /// Converte tempo local para timestamp do servidor
  DateTime localTimeToServerTimestamp(int localTimestamp) {
    final localTime = DateTime.fromMicrosecondsSinceEpoch(localTimestamp);
    return localTimeToServer(localTime);
  }

  int get roundTripTime => _roundTripTime;

  DateTime get serverTime => localTimeToServer(DateTime.now());

  void _log(String msg) {
    print('(TimeSync) -> $msg');
  }
}
