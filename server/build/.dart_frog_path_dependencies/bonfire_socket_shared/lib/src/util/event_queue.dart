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
  }) {
    _timeLine = Queue<Timeline<T>>();
  }
  late Duration? delay;
  late Queue<Timeline<T>> _timeLine;

  final void Function(T value) listen;
  final bool enabled;

  final TimeSync timeSync;

  bool _running = false;

  Duration? _delayTimeSync;

  void add(Frame<T> value) {
    if (!enabled) {
      listen.call(value.value);
      return;
    }
    _delayTimeSync ??= Duration(
      microseconds: timeSync.roundTripTime ~/ 2,
    );

    final newTimeStamp = timeSync.serverTimestampToLocal(value.timestamp);
    final frame = value.updateTime(
      newTimeStamp.add(delay ?? _delayTimeSync!).microsecondsSinceEpoch,
    );

    if (_timeLine.isNotEmpty) {
      final last = _timeLine.last;
      if (last is Frame<T>) {
        if (frame.timestamp < last.timestamp) {
          return;
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

  Future<void> _run() async {
    if (_timeLine.isEmpty) return;
    if (_running) return;
    _running = true;

    while (_timeLine.isNotEmpty) {
      final current = _timeLine.removeFirst();
      if (current is Frame<T>) {
        listen.call(current.value);
      } else if (current is Delay<T>) {
        await Future.delayed(Duration(microseconds: current.timestamp));
      }
    }
    _running = false;
  }
}
