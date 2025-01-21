import 'dart:collection';

import 'package:flutter/widgets.dart';

abstract class Timeline<T> {}

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

  final ValueChanged<T> listen;

  int _lastFrameRun = 0;
  int _lastFrameTime = 0;

  bool _running = false;
  bool _isFirstFrame = true;

  EventQueue({required this.delay, required this.listen}) {
    _timeLine = Queue<Timeline<T>>();
    _timeLine.add(Delay<T>(Duration(milliseconds: delay).inMicroseconds));
  }

  void add(Frame<T> value) {
    if (_timeLine.isNotEmpty) {
      final last = _timeLine.last;
      if (last is Frame<T>) {
        if (value.timestamp < last.timestamp) {
          return;
        }
        final delay = value.timestamp - last.timestamp;
        _timeLine.add(Delay<T>(delay));
        _timeLine.add(value);
      } else {
        _timeLine.add(value);
      }
    } else {
      // final now = DateTime.now().microsecondsSinceEpoch;
      // final elapsed = now - _lastFrameRun;
      // final targetDelay = value.timestamp - _lastFrameTime;

      // if (targetDelay > elapsed) {
      //   _timeLine.add(Delay<T>(targetDelay - elapsed));
      //   print(targetDelay - elapsed);
      // }
      _timeLine.add(value);
    }
    if (_running) return;
    _running = true;
    _run();
  }

  Future<void> _run() async {
    if (_timeLine.isEmpty) return;
    final current = _timeLine.removeFirst();
    if (current is Frame<T>) {
      print('run frame:');
      listen.call(current.value);
      _lastFrameRun = DateTime.now().microsecondsSinceEpoch;
      _lastFrameTime = current.timestamp;
    } else if (current is Delay<T>) {
      print('run delay');
     
      await Future.delayed(Duration(microseconds: current.timestamp));
    }

    if (_timeLine.isNotEmpty) {
      _run();
    } else {
      _running = false;
    }
  }
}
