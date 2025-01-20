import 'dart:collection';

import 'package:flutter/widgets.dart';

abstract class Timeline<T> {}

class Empty<T> extends Timeline<T> {}

class Delay<T> extends Timeline<T> {
  final int timestamp;
  Delay(this.timestamp);
}

class Frame<T> extends Timeline<T> {
  final T value;
  final int timestamp;
  int? late;
  int get safeLate => late ?? 0;

  Frame(this.value, this.timestamp);
}

class EventQueue<T> {
  final int delay;
  late Queue<Timeline<T>> _timeLine;

  ValueChanged<T>? listen;

  int _lastFrameRun = 0;
  int _lastFrameTime = 0;

  bool _runing = false;

  EventQueue(
    this.delay,
  ) {
    _timeLine = Queue<Timeline<T>>();
    _timeLine.add(Delay<T>(delay));
  }

  void add(Frame<T> value) {
    if (_timeLine.isNotEmpty) {
      final last = _timeLine.last;
      if (last is Frame<T>) {
        final delay = value.timestamp - last.timestamp - last.safeLate;
        if (delay > 0) {
          _timeLine.add(Delay<T>(delay));
        } else {
          value.late = delay;
        }

        _timeLine.add(value);
      } else {
        _timeLine.add(value);
      }
    } else {
      int passedTime = DateTime.now().microsecondsSinceEpoch - _lastFrameRun;
      int delay = value.timestamp - _lastFrameTime;
      delay -= passedTime;

      if (delay > 0) {
        _timeLine.add(Delay<T>(delay));
      } else {
        value.late = delay;
      }

      _timeLine.add(value);
    }
    if (_runing) return;
    _runing = true;
    _run();
  }

  Future<void> _run() async {
    if (_timeLine.isEmpty) return;
    final current = _timeLine.removeFirst();
    if (current is Frame<T>) {
      _lastFrameRun = DateTime.now().microsecondsSinceEpoch;
      _lastFrameTime = current.timestamp - current.safeLate;
      listen?.call(current.value);
    } else if (current is Delay<T>) {
      await Future.delayed(Duration(milliseconds: current.timestamp));
    }

    if (_timeLine.isNotEmpty) {
      _run();
    } else {
      _runing = false;
    }
  }
}
