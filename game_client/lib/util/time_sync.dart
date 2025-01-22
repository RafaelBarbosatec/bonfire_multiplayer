class _SyncSample {
  final Duration offset;
  final int roundTrip;

  _SyncSample(this.offset, this.roundTrip);
}

class TimeSync {
  Duration _serverOffset = Duration.zero;
  int _roundTripTime = 0;
  static const int SYNC_SAMPLES = 5;
  Future<void> synchronize(Future<DateTime> Function() getServerTime) async {
    List<_SyncSample> samples = [];
    for (int i = 0; i < SYNC_SAMPLES; i++) {
      final sample = await _collectSample(getServerTime);
      samples.add(sample);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    samples.sort((a, b) => a.roundTrip.compareTo(b.roundTrip));
    samples = samples.sublist(0, (SYNC_SAMPLES * 0.6).ceil());
    final avgOffset = Duration(
        microseconds: samples
                .map((s) => s.offset.inMicroseconds)
                .reduce((a, b) => a + b) ~/
            samples.length);
    _serverOffset = Duration(microseconds: avgOffset.inMicroseconds);
    _roundTripTime = (samples.map((s) => s.roundTrip).reduce((a, b) => a + b) /
            samples.length)
        .round();
  }

  Future<_SyncSample> _collectSample(
      Future<DateTime> Function() getServerTime) async {
    final t0 = DateTime.now().microsecondsSinceEpoch;
    final serverTime = await getServerTime();
    final t1 = DateTime.now().microsecondsSinceEpoch;
    final roundTrip = t1 - t0;
    final serverTimeMs = serverTime.microsecondsSinceEpoch;
    final offset = serverTimeMs - (t0 + (roundTrip ~/ 2));
    return _SyncSample(
      Duration(microseconds: offset),
      roundTrip,
    );
  }

// Converte um timestamp do servidor para tempo local
  DateTime serverTimeToLocal(DateTime serverTime) {
// Primeiro ajusta o offset de sincronização
    final synchronizedTime = serverTime.add(_serverOffset);
// // Depois converte para o fuso horário local
    return synchronizedTime.toLocal();
  }

  // Converte tempo local para tempo do servidor
  DateTime localTimeToServer(DateTime localTime) {
// Primeiro converte para UTC
    final utcTime = localTime.toUtc();
// Depois remove o offset de sincronização
    return utcTime.subtract(_serverOffset);
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
}
