/// Simple rate limiter using sliding window algorithm
class RateLimiter {
  RateLimiter({
    required this.maxEvents,
    required this.windowMs,
  });

  /// Maximum events allowed in the time window
  final int maxEvents;

  /// Time window in milliseconds
  final int windowMs;

  /// Timestamps of recent events
  final List<int> _eventTimestamps = [];

  /// Check if action is allowed and record it if so
  /// Returns true if allowed, false if rate limited
  bool tryConsume() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _cleanOldEvents(now);

    if (_eventTimestamps.length >= maxEvents) {
      return false; // Rate limited
    }

    _eventTimestamps.add(now);
    return true;
  }

  /// Check if action would be allowed without consuming
  bool canConsume() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _cleanOldEvents(now);
    return _eventTimestamps.length < maxEvents;
  }

  /// Remove events outside the time window
  void _cleanOldEvents(int now) {
    final cutoff = now - windowMs;
    _eventTimestamps.removeWhere((timestamp) => timestamp < cutoff);
  }

  /// Reset the rate limiter
  void reset() {
    _eventTimestamps.clear();
  }

  /// Current usage info for debugging
  Map<String, dynamic> get debugInfo => {
        'currentEvents': _eventTimestamps.length,
        'maxEvents': maxEvents,
        'windowMs': windowMs,
      };
}
