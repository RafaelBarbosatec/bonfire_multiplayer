// ignore_for_file: public_member_api_docs, inference_failure_on_instance_creation

import 'dart:collection';

import 'package:bonfire_socket_shared/src/util/time_sync.dart';

abstract class Timeline<T> {}

class Delay<T> extends Timeline<T> {
  Delay(this.timestamp);
  final int timestamp;
}

class Frame<T> extends Timeline<T> {
  Frame(this.value, this.timestamp) {
    time = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  }
  final T value;
  final int timestamp;
  late DateTime time;

  Frame<T> updateTime(int timestamp) {
    return Frame<T>(
      value,
      timestamp,
    );
  }
}

class EventQueue<T> {
  EventQueue({
    required this.timeSync,
    required this.listen,
    this.delay,
    this.enabled = true,
    this.maxReorderWindow = const Duration(milliseconds: 200),
  }) {
    _timeLine = Queue<Timeline<T>>();
    _pendingFrames = <Frame<T>>[];
  }
  late Duration? delay;
  late Queue<Timeline<T>> _timeLine;
  late List<Frame<T>> _pendingFrames;

  final void Function(T value) listen;
  final bool enabled;
  final Duration maxReorderWindow;

  final TimeSync timeSync;

  bool _running = false;
  int _lastProcessedTimestamp = 0;

  Duration? _delayTimeSync;

  void add(Frame<T> value) {
    if (!enabled) {
      listen.call(value.value);
      return;
    }
    
    // Recalculate delay based on current RTT for better accuracy
    _delayTimeSync = Duration(
      microseconds: timeSync.roundTripTime ~/ 2,
    );

    final newTimeStamp = timeSync.serverTimestampToLocal(value.timestamp);
    final frame = value.updateTime(
      newTimeStamp.add(delay ?? _delayTimeSync!).microsecondsSinceEpoch,
    );

    // Handle out-of-order events with reordering window
    if (_timeLine.isNotEmpty) {
      final last = _timeLine.last;
      if (last is Frame<T>) {
        if (frame.timestamp < last.timestamp) {
          // Check if within reorder window
          final timeDiff = last.timestamp - frame.timestamp;
          if (timeDiff < maxReorderWindow.inMicroseconds) {
            // Add to pending frames for reordering
            _pendingFrames.add(frame);
            _processPendingFrames();
            return;
          } else {
            // Too old, log and skip
            _log('Dropping event too far out of order: ${timeDiff}μs');
            return;
          }
        }
        final delay = frame.timestamp - last.timestamp;
        _timeLine.add(Delay<T>(delay));
        _timeLine.add(frame);
      } else {
        _timeLine.add(frame);
      }
    } else {
      final now = DateTime.now();
      if (frame.time.isAfter(now)) {
        final diff = frame.time.difference(now).inMicroseconds;

        if (diff > 0) {
          _timeLine.add(Delay<T>(diff));
        }
      }

      _timeLine.add(frame);
    }

    _run();
  }

  void _processPendingFrames() {
    if (_pendingFrames.isEmpty) return;

    // Sort pending frames by timestamp
    _pendingFrames.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Reconstruct timeline with properly ordered frames
    final allFrames = <Frame<T>>[];
    
    // Extract current frames from timeline
    for (final item in _timeLine) {
      if (item is Frame<T>) {
        allFrames.add(item);
      }
    }
    
    // Add pending frames
    allFrames.addAll(_pendingFrames);
    _pendingFrames.clear();

    // Sort all frames
    allFrames.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Rebuild timeline
    _timeLine.clear();
    for (var i = 0; i < allFrames.length; i++) {
      if (i == 0) {
        final now = DateTime.now();
        if (allFrames[i].time.isAfter(now)) {
          final diff = allFrames[i].time.difference(now).inMicroseconds;
          if (diff > 0) {
            _timeLine.add(Delay<T>(diff));
          }
        }
        _timeLine.add(allFrames[i]);
      } else {
        final delay = allFrames[i].timestamp - allFrames[i - 1].timestamp;
        if (delay > 0) {
          _timeLine.add(Delay<T>(delay));
        }
        _timeLine.add(allFrames[i]);
      }
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('(EventQueue) -> $message');
  }

  Future<void> _run() async {
    if (_timeLine.isEmpty) return;
    if (_running) return;
    _running = true;

    while (_timeLine.isNotEmpty) {
      final current = _timeLine.removeFirst();
      if (current is Frame<T>) {
        // Process frame immediately, delays handled before frames
        _lastProcessedTimestamp = current.timestamp;
        listen.call(current.value);
      } else if (current is Delay<T>) {
        // Cap maximum delay to prevent excessive blocking
        final delayMicros = current.timestamp.clamp(0, 100000); // Max 100ms
        if (delayMicros > 0) {
          await Future.delayed(Duration(microseconds: delayMicros));
        }
      }
    }
    _running = false;
  }
}
