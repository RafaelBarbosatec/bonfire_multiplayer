class TimeSync {
  Duration _serverDifference = Duration.zero;
  int _roundTripTime = 0;

  Future<void> synchronize(Future<DateTime> Function() getServerTime) async {
    try {
      final DateTime requestTime = DateTime.now();
      final serverTime = await getServerTime();
      final DateTime responseTime = DateTime.now();
  
      final Duration roundTripTime = responseTime.difference(requestTime);
      _roundTripTime = roundTripTime.inMicroseconds;
      final DateTime adjustedServerTime = serverTime.add(roundTripTime ~/ 2);

      _serverDifference = adjustedServerTime.difference(responseTime);
      _log('diff: $_serverDifference');
      _log('roundTripTime: $roundTripTime');
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Converte um timestamp do servidor para tempo local
  DateTime serverTimeToLocal(DateTime serverTime) {
// Primeiro ajusta o offset de sincronização
    final synchronizedTime = serverTime.subtract(_serverDifference);
// // Depois converte para o fuso horário local
    return synchronizedTime;
  }

  // Converte tempo local para tempo do servidor
  DateTime localTimeToServer(DateTime localTime) {
    final utcTime = localTime;
// Depois remove o offset de sincronização
    return utcTime.add(_serverDifference);
  }

  // Converte um timestamp do servidor para tempo local
  DateTime serverTimestampToLocal(int serverTimestamp) {
    final serverTime = DateTime.fromMicrosecondsSinceEpoch(serverTimestamp);
    return serverTimeToLocal(serverTime);
  }

  // Converte tempo local para timestamp do servidor
  DateTime localTimeToServerTimestamp(int localTimestamp) {
    final localTime = DateTime.fromMicrosecondsSinceEpoch(localTimestamp);
    return localTimeToServer(localTime);
  }

  int get roundTripTime => _roundTripTime;

  DateTime get serverTime => localTimeToServer(DateTime.now());

  void _log(String msg){
    print('(TimeSync) -> $msg');
  }
}
