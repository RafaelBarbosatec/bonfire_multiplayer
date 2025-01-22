import 'dart:collection';

import 'package:bonfire_multiplayer/util/time_sync.dart';
import 'package:flutter/widgets.dart';

abstract class Timeline<T> {}

class Delay<T> extends Timeline<T> {
  final int timestamp;
  Delay(this.timestamp);
}

class Frame<T> extends Timeline<T> {
  final T value;
  final int timestamp;
  late DateTime time;

  Frame(this.value, this.timestamp) {
    time = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  }

  Frame<T> updateTime(int timestamp) {
    return Frame<T>(
      value,
      timestamp,
    );
  }
}

class EventQueue<T> {
  late Duration delay;
  late Queue<Timeline<T>> _timeLine;

  final ValueChanged<T> listen;

  final TimeSync timeSync;

  bool _running = false;

  EventQueue({
    int? delay,
    required this.timeSync,
    required this.listen,
  }) {
    if (delay != null) {
      this.delay = Duration(milliseconds: delay);
    } else {
      this.delay = Duration(
        microseconds:
            timeSync.roundTripTime < 100 ? timeSync.roundTripTime : 100,
      );
    }

    _timeLine = Queue<Timeline<T>>();
  }

  void add(Frame<T> value) {
    final newTimeStamp = timeSync.serverTimestampToLocal(value.timestamp);

    final frame = value.updateTime(
      newTimeStamp
          .add(Duration(microseconds: timeSync.roundTripTime))
          .microsecondsSinceEpoch,
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
      final diff = frame.time.difference(DateTime.now()).inMicroseconds;
      if (diff > 0) {
        _timeLine.add(Delay<T>(diff));
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
