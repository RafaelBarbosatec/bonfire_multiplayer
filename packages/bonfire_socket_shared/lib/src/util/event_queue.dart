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

  Duration? _delayTimeSync;

  void add(Frame<T> value) {
    if (!enabled) {
      listen.call(value.value);
      return;
    }
    
    // Calculate delay based on RTT only if not set or RTT changed significantly
    if (_delayTimeSync == null || 
        (_delayTimeSync!.inMicroseconds - (timeSync.roundTripTime ~/ 2)).abs() > 10000) {
      _delayTimeSync = Duration(
        microseconds: timeSync.roundTripTime ~/ 2,
      );
    }

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

    // Insert each pending frame in the correct position
    for (final pendingFrame in _pendingFrames) {
      _insertFrameInOrder(pendingFrame);
    }
    _pendingFrames.clear();
  }

  void _insertFrameInOrder(Frame<T> frame) {
    // Convert timeline to list for easier manipulation
    final items = _timeLine.toList();
    _timeLine.clear();

    // Find insertion point
    int insertIndex = -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i] is Frame<T>) {
        final existingFrame = items[i] as Frame<T>;
        if (frame.timestamp < existingFrame.timestamp) {
          insertIndex = i;
          break;
        }
      }
    }

    // If no insertion point found, add at end
    if (insertIndex == -1) {
      insertIndex = items.length;
    }

    // Rebuild timeline with frame inserted at correct position
    Frame<T>? previousFrame;
    for (int i = 0; i < items.length; i++) {
      if (i == insertIndex) {
        // Insert the new frame here
        if (previousFrame != null) {
          final delayBefore = frame.timestamp - previousFrame.timestamp;
          if (delayBefore > 0) {
            _timeLine.add(Delay<T>(delayBefore));
          }
        } else {
          // First frame, check against current time
          final now = DateTime.now();
          if (frame.time.isAfter(now)) {
            final diff = frame.time.difference(now).inMicroseconds;
            if (diff > 0) {
              _timeLine.add(Delay<T>(diff));
            }
          }
        }
        _timeLine.add(frame);
        previousFrame = frame;
      }

      // Skip delays, recalculate them based on frames
      if (items[i] is Frame<T>) {
        final currentFrame = items[i] as Frame<T>;
        if (previousFrame != null) {
          final delayBefore = currentFrame.timestamp - previousFrame.timestamp;
          if (delayBefore > 0) {
            _timeLine.add(Delay<T>(delayBefore));
          }
        } else if (i == 0) {
          // First frame, check against current time
          final now = DateTime.now();
          if (currentFrame.time.isAfter(now)) {
            final diff = currentFrame.time.difference(now).inMicroseconds;
            if (diff > 0) {
              _timeLine.add(Delay<T>(diff));
            }
          }
        }
        _timeLine.add(currentFrame);
        previousFrame = currentFrame;
      }
    }

    // Handle case where frame should be added at the end
    if (insertIndex == items.length && items.isNotEmpty) {
      if (previousFrame != null) {
        final delayBefore = frame.timestamp - previousFrame.timestamp;
        if (delayBefore > 0) {
          _timeLine.add(Delay<T>(delayBefore));
        }
      }
      _timeLine.add(frame);
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
